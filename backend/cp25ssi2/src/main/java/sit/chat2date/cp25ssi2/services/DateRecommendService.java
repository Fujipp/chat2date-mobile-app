package sit.chat2date.cp25ssi2.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import sit.chat2date.cp25ssi2.dto.ConfirmationRequest;
import sit.chat2date.cp25ssi2.dto.PlaceDTO;
import sit.chat2date.cp25ssi2.dto.RecommendationResponse;
import sit.chat2date.cp25ssi2.entities.*;
import sit.chat2date.cp25ssi2.enums.AppointmentStatus;
import sit.chat2date.cp25ssi2.enums.ConfirmAction;
import sit.chat2date.cp25ssi2.enums.ConfirmationStatus;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.LockedException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceptions.TooManyRequestException;
import sit.chat2date.cp25ssi2.repositories.*;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
public class DateRecommendService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MatchRepository matchRepository;

    @Autowired
    private UserLocationRepository userLocationRepository;

    @Autowired
    private PlaceRepository placeRepository;

    @Autowired
    private StringRedisTemplate redis;
    @Autowired
    private ObjectMapper objectMapper;
    @Autowired
    private RestTemplate restTemplate;
    @Autowired
    private PlaceConfirmationRepository placeConfirmationRepository;
    @Autowired
    private AppointmentRepository appointmentRepository;

    @Value("${google.map.id}")
    private String googleId;

    public ResponseEntity<RecommendationResponse> DateRecommendationById(String roomId, String mode, String userTarget, int range, String accessToken) throws JsonProcessingException {
        User user = extractToken(accessToken);

        Match match = matchRepository.findById(Integer.valueOf(roomId))
                .orElseThrow(() -> new NotFoundException("Match not found with id: " + roomId));

        if (!Objects.equals(user.getUserId(), match.getUserId1().getUserId()) &&
                !Objects.equals(user.getUserId(), match.getUserId2().getUserId())) {
            throw new ForbiddenAccessException("Forbidden: cannot access another user's data");
        }

        String lockKey = "lock:room:" + roomId;
        String leaderKey = "room_leader:" + user.getUserId();
        String dataKey = buildDataKey(roomId, mode, userTarget);

        String cachedData = (String) redis.opsForValue().get(dataKey);
        if (cachedData != null) {
            return ResponseEntity.ok(objectMapper.readValue(cachedData, RecommendationResponse.class));
        }

        String rateKey = "rate_limit:spin:" + user.getUserId();
        if (redis.hasKey(rateKey)) {
            throw new TooManyRequestException("Too many request: need to wait for a rate limit");
        }

        Object leaderObj = redis.opsForValue().get(leaderKey);
        String currentLeaderId;

        if (leaderObj == null) {
            currentLeaderId = String.valueOf(user.getUserId());
            redis.opsForValue().set(leaderKey, currentLeaderId, Duration.ofMinutes(30));
        } else {
            currentLeaderId = redis.opsForValue().get(leaderKey);
        }

        if (Boolean.TRUE.equals(redis.opsForValue().setIfAbsent(lockKey, "processing", Duration.ofSeconds(15)))) {
            try {
                Optional<Match> matchById = matchRepository.findById(Integer.valueOf(roomId));
                UserLocation user1Location = userLocationRepository.findFirstByUser_UserId(String.valueOf(matchById.get().getUserId1().getUserId()));
                UserLocation user2Location = userLocationRepository.findFirstByUser_UserId(String.valueOf(matchById.get().getUserId2().getUserId()));
                boolean isUser1Me = String.valueOf(matchById.get().getUserId1().getUserId()).equals(user.getUserId());
                UserLocation myLoc = isUser1Me ? user1Location : user2Location;
                UserLocation partnerLoc = isUser1Me ? user2Location : user1Location;

                double targetLat, targetLng;
                if (mode.equals("DISTANCE")) {
                    UserLocation target = "Partner".equalsIgnoreCase(userTarget) ? partnerLoc : myLoc;
                    targetLat = target.getLatitude().doubleValue();
                    targetLng = target.getLongtitude().doubleValue();
                } else {
                    Coordinates coordinates = calculateMidpoint(user1Location, user2Location);
                    targetLng = coordinates.lng;
                    targetLat = coordinates.lat;
                }
                List<PlaceDTO> allPlaces = fetchGooglePlaces(targetLat, targetLng, range);

                Collections.shuffle(allPlaces);
                List<PlaceDTO> selectedPlaces = allPlaces.stream().limit(10).collect(Collectors.toList());

                int winningIndex = selectedPlaces.isEmpty() ? -1 : new Random().nextInt(selectedPlaces.size());

                RecommendationResponse finalResponse = new RecommendationResponse(
                        roomId, mode, currentLeaderId, winningIndex, selectedPlaces
                );

                redis.opsForValue().set(dataKey, objectMapper.writeValueAsString(finalResponse), Duration.ofMinutes(30));
                redis.opsForValue().set(rateKey, "1", 15, TimeUnit.SECONDS);

                return ResponseEntity.ok(finalResponse);
            } finally {
                redis.delete(lockKey);
            }
        }

        throw new LockedException("Your partner still spinning");
    }

    public PlaceConfirmation confirmPlace(String roomId, String accessToken, ConfirmationRequest confirmationRequest) {
        User user = extractToken(accessToken);

        Match match = matchRepository.findById(Integer.valueOf(roomId))
                .orElseThrow(() -> new NotFoundException("Match not found with id: " + roomId));

        if (!Objects.equals(user.getUserId(), match.getUserId1().getUserId()) &&
                !Objects.equals(user.getUserId(), match.getUserId2().getUserId())) {
            throw new ForbiddenAccessException("Forbidden: cannot access another user's data");
        }

        String targetDisplayName = confirmationRequest.getPlaceName();
        Place findPlace = placeRepository.findPlaceByPlaceName(targetDisplayName);

        Place placeToUse;

        if (findPlace == null) {
            String mode = confirmationRequest.getMode();
            String userTarget = confirmationRequest.getUserTarget();
            String dataKey = buildDataKey(roomId, mode, userTarget);

            String cachedData = (String) redis.opsForValue().get(dataKey);
            if (cachedData == null) {
                throw new NotFoundException("Recommendation data not found or expired (Place must be created from recommended data)");
            }

            try {
                RecommendationResponse recommendation = objectMapper.readValue(cachedData, RecommendationResponse.class);
                PlaceDTO selectedPlaceFromRedis = recommendation.getPlaces().stream()
                        .filter(p -> p.getName().equals(targetDisplayName))
                        .findFirst()
                        .orElseThrow(() -> new NotFoundException("Place selected not found in database and recommendation data"));

                Place newPlace = new Place();
                newPlace.setPlaceId(selectedPlaceFromRedis.getGooglePlaceId());
                newPlace.setPlaceName(selectedPlaceFromRedis.getName());
                newPlace.setAddress(selectedPlaceFromRedis.getAddress());
                newPlace.setLongitude(BigDecimal.valueOf(selectedPlaceFromRedis.getLongitude()));
                newPlace.setLatitude(BigDecimal.valueOf(selectedPlaceFromRedis.getLatitude()));
                placeToUse = placeRepository.save(newPlace);
            } catch (JsonProcessingException e) {
                throw new RuntimeException("Error parsing Redis data", e);
            }
        } else {
            placeToUse = findPlace;
        }

        Optional<PlaceConfirmation> placeConfirmationIsExist =
                placeConfirmationRepository.findFirstByMatchAndStatusOrderByConfirmIdDesc(match.getId(), ConfirmationStatus.PENDING);

        PlaceConfirmation pc;
        if (placeConfirmationIsExist.isPresent()) {
            pc = placeConfirmationIsExist.get();
        } else {
            pc = new PlaceConfirmation();
            pc.setMatch(match.getId());
            pc.setPlace(placeToUse.getPlaceId());
            pc.setUser1Confirmed(ConfirmAction.BLANK);
            pc.setUser2Confirmed(ConfirmAction.BLANK);
            pc.setStatus(ConfirmationStatus.PENDING);
        }

        if (Objects.equals(user.getUserId(), match.getUserId1().getUserId())) {
            pc.setUser1Confirmed(confirmationRequest.getAction());
        } else {
            pc.setUser2Confirmed(confirmationRequest.getAction());
        }

        if (pc.getUser1Confirmed() == ConfirmAction.AGREED && pc.getUser2Confirmed() == ConfirmAction.AGREED) {
            pc.setStatus(ConfirmationStatus.AGREED);
            Appointment appointment = new Appointment();
            appointment.setMatch(match);
            appointment.setPlace(placeToUse);
            appointment.setStatus(AppointmentStatus.PLACE_SELECTED);
            appointmentRepository.save(appointment);
        } else if (pc.getUser1Confirmed() == ConfirmAction.DISAGREED || pc.getUser2Confirmed() == ConfirmAction.DISAGREED) {
            if (pc.getUser1Confirmed() != ConfirmAction.BLANK && pc.getUser2Confirmed() != ConfirmAction.BLANK) {
                pc.setStatus(ConfirmationStatus.REJECTED);
            }
        }

        return placeConfirmationRepository.save(pc);
    }

    public ConfirmAction getMyConfirmationStatus(String roomId, String accessToken) {
        User user = extractToken(accessToken);

        // 1. หา Match เพื่อระบุว่า User นี้คือ User1 หรือ User2 ของห้องนี้
        Match match = matchRepository.findById(Integer.valueOf(roomId))
                .orElseThrow(() -> new NotFoundException("Match not found with id: " + roomId));

        // 2. ดึงรายการ Confirmation ล่าสุดที่ยัง PENDING อยู่
        Optional<PlaceConfirmation> pendingConfirmation = placeConfirmationRepository
                .findFirstByMatchAndStatusOrderByConfirmIdDesc(match.getId(), ConfirmationStatus.PENDING);

        // 3. ถ้าไม่มีรายการ PENDING เลย แสดงว่ายังไม่มีใครเลือกสถานที่ หรือจบดีลไปแล้ว
        if (pendingConfirmation.isEmpty()) {
            return ConfirmAction.BLANK;
        }

        PlaceConfirmation pc = pendingConfirmation.get();
        String currentUserId = user.getUserId();

        // 4. เช็คว่า User คนที่เรียก API นี้คือใคร แล้วคืนค่า Action ของคนนั้น
        if (Objects.equals(currentUserId, match.getUserId1().getUserId())) {
            return pc.getUser1Confirmed(); // คืนค่า AGREE, DISAGREE หรือ BLANK ของ User1
        } else if (Objects.equals(currentUserId, match.getUserId2().getUserId())) {
            return pc.getUser2Confirmed(); // คืนค่า AGREE, DISAGREE หรือ BLANK ของ User2
        } else {
            throw new ForbiddenAccessException("Forbidden: cannot access another user's data");
        }
    }


    private String buildDataKey(String roomId, String mode, String userTarget) {
        String key = "room_data:" + roomId + ":" + mode;
        if ("DISTANCE".equals(mode)) {
            key += ":" + userTarget;
        }
        return key;
    }

    public List<PlaceDTO> fetchGooglePlaces(double midLat, double midLng, int range) throws
            JsonProcessingException {
        String apiKey = googleId;
        String url = "https://places.googleapis.com/v1/places:searchText";

        // 1. เตรียม Headers
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("X-Goog-Api-Key", apiKey);
        headers.set("X-Goog-FieldMask", "places.displayName,places.location,places.formattedAddress");

        // 2. เตรียม Body (ตามรูป Postman ของคุณ)
        Map<String, Object> circle = Map.of(
                "center", Map.of("latitude", midLat, "longitude", midLng),
                "radius", (double) range
        );
        Map<String, Object> requestBody = Map.of(
                "textQuery", "สถานที่เดท",
                "languageCode", "th",
                "locationBias", Map.of("circle", circle)
        );

        // 3. ยิง Request
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
        ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);

        // 4. แปลง JSON String เป็น List<PlaceDTO>
        JsonNode root = objectMapper.readTree(response.getBody());
        return parsePlaces(root);
    }

    private List<PlaceDTO> parsePlaces(JsonNode root) {
        List<PlaceDTO> dtos = new ArrayList<>();
        JsonNode places = root.path("places");

        if (places.isArray()) {
            for (JsonNode place : places) {
                dtos.add(new PlaceDTO(
                        place.path("id").asText(),
                        place.path("displayName").path("text").asText(),
                        place.path("location").path("latitude").asDouble(),
                        place.path("location").path("longitude").asDouble(),
                        place.path("formattedAddress").asText()
                ));
            }
        }
        return dtos;
    }

    public Coordinates calculateMidpoint(UserLocation user1, UserLocation user2) {
        double midLat = (user1.getLatitude().doubleValue() + user2.getLatitude().doubleValue()) / 2;
        double midLng = (user1.getLongtitude().doubleValue() + user2.getLongtitude().doubleValue()) / 2;

        return new Coordinates(midLat, midLng);
    }

    public User extractToken(String accessToken) {
        String token = accessToken.substring(7);
        DecodedJWT jwt = JWT.decode(token);
        String sub = jwt.getClaim("sub").asString();

        User user = (sub.length() == 10)
                ? userRepository.findByPhoneNumber(sub).orElseThrow()
                : userRepository.findByEmail(sub).orElseThrow();
        return user;
    }

    @Data
    @AllArgsConstructor
    public static class Coordinates {
        private double lat;
        private double lng;
    }
}

