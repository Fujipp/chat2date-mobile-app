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
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import sit.chat2date.cp25ssi2.dto.ConfirmationRequest;
import sit.chat2date.cp25ssi2.dto.PlaceDTO;
import sit.chat2date.cp25ssi2.dto.RecommendationResponse;
import sit.chat2date.cp25ssi2.dto.SpinStatusResponse;
import sit.chat2date.cp25ssi2.entities.*;
import sit.chat2date.cp25ssi2.enums.AppointmentStatus;
import sit.chat2date.cp25ssi2.enums.ConfirmAction;
import sit.chat2date.cp25ssi2.enums.ConfirmationStatus;
import sit.chat2date.cp25ssi2.enums.MessageType;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.LockedException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceptions.TooManyRequestException;
import sit.chat2date.cp25ssi2.repositories.*;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
public class DateRecommendService {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

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
    @Autowired
    private ChatService chatService;
    @Autowired
    private MessageRepository messageRepository;
    @Autowired
    private RelationshipStatsRepository relationshipStatsRepository;
    @Autowired
    private AppointmentService appointmentService;

    @Value("${google.map.id}")
    private String googleId;

    public ResponseEntity<RecommendationResponse> DateRecommendationById(String roomId, String mode, String userTarget, int range, String accessToken, boolean forceRefresh) throws JsonProcessingException {
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

        if (!forceRefresh) {
            String cachedData = (String) redis.opsForValue().get(dataKey);
            if (cachedData != null) {
                String actualLeaderId = redis.opsForValue().get("room_leader:" + user.getUserId());

                Map<String, Object> spinSignal = new HashMap<>();
                spinSignal.put("type", "FRESH_MODE"); // บอก Flutter ว่า "เริ่มหมุนได้!"
                spinSignal.put("mode", mode);
                spinSignal.put("userTarget", userTarget);
                spinSignal.put("range", range);
                spinSignal.put("leaderId", actualLeaderId);
                spinSignal.put("data", cachedData);

                messagingTemplate.convertAndSend("/topic/spin/" + roomId, spinSignal);
                return ResponseEntity.ok(objectMapper.readValue(cachedData, RecommendationResponse.class));
            }
        }

        String modeIdentifier = "MIDPOINT".equalsIgnoreCase(mode) ? "MIDPOINT" : "DISTANCE_" + userTarget.toUpperCase();
        String rateKey = "rate_limit:spin:" + user.getUserId() + ":" + modeIdentifier;
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
                UserLocation user1Location = userLocationRepository.findFirstByUser_UserId(match.getUserId1().getUserId());
                UserLocation user2Location = userLocationRepository.findFirstByUser_UserId(match.getUserId2().getUserId());
                boolean isUser1Me = String.valueOf(match.getUserId1().getUserId()).equals(user.getUserId());
                UserLocation myLoc = isUser1Me ? user1Location : user2Location;
                UserLocation partnerLoc = isUser1Me ? user2Location : user1Location;

                double targetLat, targetLng;
                if ("DISTANCE".equals(mode)) {
                    UserLocation target = "Partner".equalsIgnoreCase(userTarget) ? partnerLoc : myLoc;
                    targetLat = target.getLatitude().doubleValue();
                    targetLng = target.getLongitude().doubleValue();
                } else {
                    Coordinates coordinates = calculateMidpoint(user1Location, user2Location);
                    targetLng = coordinates.lng;
                    targetLat = coordinates.lat;
                }
                List<PlaceDTO> allPlaces = fetchGooglePlaces(targetLat, targetLng, range, mode, userTarget, true);

                Collections.shuffle(allPlaces);
                List<PlaceDTO> selectedPlaces = allPlaces.stream().limit(10).collect(Collectors.toList());

                RecommendationResponse finalResponse = new RecommendationResponse(
                        roomId, mode, currentLeaderId, selectedPlaces
                );

                Map<String, Object> spinSignal = new HashMap<>();
                spinSignal.put("type", "FRESH_MODE");
                spinSignal.put("mode", mode);
                spinSignal.put("userTarget", userTarget);
                spinSignal.put("range", range);
                spinSignal.put("leaderId", currentLeaderId);
                spinSignal.put("data", finalResponse);

                messagingTemplate.convertAndSend("/topic/spin/" + roomId, spinSignal);
                redis.opsForValue().set(rateKey, "active", Duration.ofSeconds(10));
                redis.opsForValue().set(dataKey, objectMapper.writeValueAsString(finalResponse), Duration.ofMinutes(30));

                return ResponseEntity.ok(finalResponse);
            } finally {
                redis.delete(lockKey);
            }
        }

        throw new LockedException("Your partner still retrieving data");
    }

    public void triggerSpin(String roomId) {
        int winningIndex = new Random().nextInt(10);
        Map<String, Object> spinCmd = new HashMap<>();
        spinCmd.put("type", "CMD_SPIN_START");
        spinCmd.put("winningIndex", winningIndex);

        messagingTemplate.convertAndSend("/topic/spin/" + roomId, spinCmd);
    }

    public void triggerCloseModal(String roomId, String accessToken) {
        User user = extractToken(accessToken);

        String leaderKey = "room_leader:" + user.getUserId();
        if (!redis.hasKey(leaderKey)) {
            throw new ForbiddenAccessException("Only the room leader can close the modal.");
        }

        Match match = matchRepository.findById(Integer.valueOf(roomId))
                .orElseThrow(() -> new NotFoundException("Match not found"));
        redis.delete("room_leader:" + match.getUserId1().getUserId());
        redis.delete("room_leader:" + match.getUserId2().getUserId());

        Set<String> keys = redis.keys("room_data:" + roomId + ":*");
        if (!keys.isEmpty()) {
            redis.delete(keys);
        }

        redis.delete("lock:room:" + roomId);

        Map<String, Object> closeCmd = new HashMap<>();
        closeCmd.put("type", "CMD_CLOSE_MODAL");
        messagingTemplate.convertAndSend("/topic/spin/" + roomId, closeCmd);
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
                newPlace.setImageUrl(selectedPlaceFromRedis.getImageUrl());
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

            chatService.sendSystemMessage(
                    Integer.parseInt(roomId),
                    "สุ่มได้ไปเที่ยวที่ " + placeToUse.getPlaceName() + " !!! | คุณอยากไปเที่ยว " + placeToUse.getPlaceName() + " หรือไม่ | ตอบแล้ว 0/2",
                    MessageType.DATE
            );
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
            pc.setStatus(ConfirmationStatus.REJECTED);
        }

        int respondCount = 0;
        if (pc.getUser1Confirmed() == ConfirmAction.AGREED) respondCount++;
        if (pc.getUser2Confirmed() == ConfirmAction.AGREED) respondCount++;
        editMessage(roomId, placeToUse, respondCount, pc.getStatus());

        return placeConfirmationRepository.save(pc);
    }

    public void editMessage(String roomId, Place place, int respondCount, ConfirmationStatus status) {
        Optional<Message> messageOpt = messageRepository.findFirstByRoomIdAndMessageTypeOrderByCreatedAtDesc(
                Integer.valueOf(roomId), MessageType.DATE);

        if (messageOpt.isPresent()) {
            Message messageToUpdate = messageOpt.get();
            String messageText;

            if (status == ConfirmationStatus.AGREED) {
                // 🥳 กรณีสำเร็จ
                messageText = "กรุณากรอกวันที่ออกเดตของคุณในปฏิทิน";
                messageToUpdate.setMessageType(MessageType.SUCCESS);
            } else if (status == ConfirmationStatus.REJECTED) {
                // 😔 กรณีไม่เห็นตรงกัน
                messageText = "คุณทั้ง 2 คนมีความคิดเห็นที่ไม่ตรงกัน";
                messageToUpdate.setMessageType(MessageType.FAIL);
            } else {
                // ⏳ กรณีรอคนกด (Pending)
                messageText = "สุ่มได้ไปเที่ยวที่ " + place.getPlaceName() + " !!! | คุณอยากไปเที่ยว " + place.getPlaceName() + " หรือไม่ | ตอบแล้ว " + respondCount + "/2";
            }
            messageToUpdate.setMessage(messageText);
            messageToUpdate.setCreatedAt(LocalDateTime.now());
            messageRepository.save(messageToUpdate);

            // ส่ง WebSocket ไปบอก Flutter
            messagingTemplate.convertAndSend("/topic/chat/" + roomId, messageToUpdate);
        }
    }


    public ConfirmAction getMyConfirmationStatus(String roomId, String accessToken) {
        User user = extractToken(accessToken);

        Match match = matchRepository.findById(Integer.valueOf(roomId))
                .orElseThrow(() -> new NotFoundException("Match not found with id: " + roomId));

        Optional<PlaceConfirmation> pendingConfirmation = placeConfirmationRepository
                .findFirstByMatchAndStatusOrderByConfirmIdDesc(match.getId(), ConfirmationStatus.PENDING);

        if (pendingConfirmation.isEmpty()) {
            return ConfirmAction.BLANK;
        }

        PlaceConfirmation pc = pendingConfirmation.get();
        String currentUserId = user.getUserId();


        if (Objects.equals(currentUserId, match.getUserId1().getUserId())) {
            return pc.getUser1Confirmed();
        } else if (Objects.equals(currentUserId, match.getUserId2().getUserId())) {
            return pc.getUser2Confirmed();
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

    public List<PlaceDTO> fetchGooglePlaces(double midLat, double midLng, int range, String mode, String userTarget, boolean mock) throws
            JsonProcessingException {
        if (mock) {
            return getMockPlaces(mode, userTarget);
        } else {
            String apiKey = googleId;
            String url = "https://places.googleapis.com/v1/places:searchText";

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("X-Goog-Api-Key", apiKey);
            headers.set("X-Goog-FieldMask", "places.id,places.displayName,places.location,places.formattedAddress,places.photos");


            Map<String, Object> circle = Map.of(
                    "center", Map.of("latitude", midLat, "longitude", midLng),
                    "radius", (double) range
            );
            Map<String, Object> requestBody = Map.of(
                    "textQuery", "สถานที่เดท",
                    "languageCode", "th",
                    "locationBias", Map.of("circle", circle)
            );

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);
            ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);

            JsonNode root = objectMapper.readTree(response.getBody());
            return parsePlaces(root);
        }
    }

    private List<PlaceDTO> getMockPlaces(String mode, String userTarget) {
        List<PlaceDTO> dtos = new ArrayList<>();

        // ---------------------------------------------------------
        // 1. ชุดข้อมูลโหมด MIDPOINT (สถานที่พบกันครึ่งทาง)
        // ---------------------------------------------------------
        if ("MIDPOINT".equalsIgnoreCase(mode)) {
            dtos.add(new PlaceDTO("ChIJdQl-hnG74jAR1WRYUQkZ7Nw", "บีชชี่ คาเฟ่", 13.5921443, 100.4307465, "9 ถ. บางขุนเทียน กรุงเทพฯ",
                    "https://places.googleapis.com/v1/places/ChIJdQl-hnG74jAR1WRYUQkZ7Nw/photos/ATCDNfVrh3NKl0TO0yLBuhXXsBFnLj-BR7OOXmIQj6tWZLbtpbVuuntpYXCfWfv7yFv-6gqgMGzcJZlONxonlL8kEmJOn6u2FCb4ju3hSu4ePh0oZoc_ouuo7hRj9i4T2m0pYypOyXSYlAhdPuCYoeNDVsxoXYwxMQ3iaZ45s0cj6graJH3sqzs-GlFKMv8Cg8fhCesA0gE4mA3BCITDqcq0QcpumqeQ_pd7IynJkvvQ5eeUcVBmdM8ew0E5m8j_rugAWAK3Waym4cDquyggpIwT-sRguj4M_6-YEmMlX0YpBaKGIu-uA6x6_Tik-HFRPBBb9rNHC6ADHPXlCfX4CvK_Xp16OcM6FHaP8ErTNQNG7qe7GpiERc8CHM7rY6p7s-bEfo8n_4Sl_dpYB11Rcy5QtijXdURzOJUJe5G9C-yL7Jc/media?key=AIzaSyA0CLruE_Q-XXorq9Vya2K7Rbz0w692FaM&maxHeightPx=400"));
            dtos.add(new PlaceDTO("ChIJ8UJNsd2E4jARFSgf1sdGJUQ", "พุทธสถานเชิงท่า-หน้าโบสถ์", 13.893991, 100.4919375, "อำเภอเมืองนนทบุรี",
                    "https://places.googleapis.com/v1/places/ChIJ8UJNsd2E4jARFSgf1sdGJUQ/photos/ATCDNfV_YHxuaxHCuaLnJVf6czJ5alGbl3CDHIWdJoTIwdvC78hTeFi-U7o5GcgxxEw7EoPpAaeIJYHYu4tNaKeqUT18glDgbMMM2_vp1PD07JjjlmTM6C-dN-bXs6bUFU15U-cDjje5qHZut8Zsrbjy0dLvXbdl-NZyYuuW7ZiJ7vbhaW1P7IYBT52DZOUBFMl8oU56ew4lRa-wp9ynI-T7kbPnUNiB8K0lgL8LUwFFomFBFA1vzoaBjDK9pNNATBW5DuVtntqGzKk_IDG6JiKzLmuP5-FlakYIysyLJ0YMJ3jZBW1HPkqCvmKXj9BzxR__1-_aCz5nqLxk0Y8FG3MHZDj0WBbmwk7snUS5c6Y4a4qQMCXlWK3LvUPEYBqH8e74Pnj-aTJkueJfUy3cOlZPDjiOHJ-Ek5zCmILjTLjvFZHu4g/media?key=AIzaSyA0CLruE_Q-XXorq9Vya2K7Rbz0w692FaM&maxHeightPx=400"));
            dtos.add(new PlaceDTO("ChIJAcuELQ2Z4jAR3q0DmU_NKkQ", "พิพิธภัณฑสถานแห่งชาติ หอศิลป", 13.7590737, 100.4939671, "เขตพระนคร กรุงเทพฯ",
                    "https://places.googleapis.com/v1/places/ChIJAcuELQ2Z4jAR3q0DmU_NKkQ/photos/ATCDNfX6P0vML76K4HsTC6dIu7GD9hQrJsU2YlL3wv2Lv0gR1oCN27hJT_IUNU-pwdvc8a0mV3LtAFzSeOTfU5qiPlOcjbMCcNvcuF0Wupruk3zjH2K5ciE16YMQXsERHGoBcIYy6mopHNadfbqqR6jXPjlRSmQuIAbQ0yW-GBnNCUtnzSyyLLiBEIxgmcmP3-quPVhh2VOpC09zVNoLSnnStf3qhu2w1JQ_rLawq7pDOuSTSJgrkmPnZARjDB4QTeZP7gu-z1QySmMFEcWfkls8m0UPc9u0O3BQu5N8D156RxSsMc1jtA8Dkwc4-OTHcv0MI9KoFRXh8OkUMHsYQ1zj6VeZZNgTffs--ozmU-c6qXVd2oymPHCfKhTYLwqfrwcwPKx7dYEpvhmRQbNlNqPOQd0LZ5E2HdWqL8e8dXQV8CqAkFv1gGd-9us7Zrr_GaE7/media?key=" + googleId + "&maxHeightPx=400"));
            dtos.add(new PlaceDTO("ChIJVfgvAGqZ4jARHITMd3WtF1s", "Street Art", 13.7182875, 100.4588516, "ภาษีเจริญ กรุงเทพฯ",
                    "https://places.googleapis.com/v1/places/ChIJVfgvAGqZ4jARHITMd3WtF1s/photos/ATCDNfXhXofsEbv--wzGdQZjQqThnWxqvn9ppqNcvvzOCQENKAvDbH7_EFFNdZBO6m14EqqvrYBgyzcp_40seJcMEE1b-O9R9Xe819FIXUCTKGNVTiYNr4HLvQP0C8JuEI4RcmE4Mrt6owL7MwaUR8UJjcgDz4K-psLOnyn8CJRN4RDkAwJzke9dvrRDM7zT4m18tJ9jJHkEKfS23JNHGKVv_o8D5UxyN2Xv36gnbHlJQQfJjzfxSd0hFkmr3YO1jeHXYtQv0SEVE2T8MOAa19Q8iVSrYe-csvTrFB0gkyqH68OlikH5f2dbWgwYh5NxV7Ipfb3VkZcw6AYlRFro1dF5q2MI4_xcf6R-xCItHYk_ALFVG8qgdHkhMWNEY0MDpYdrznjXdhwi19qXLnPycW7ptm-cAhv7Sd1zypcqjnLfhZBPjJv3/media?key=" + googleId + "&maxHeightPx=400"));
            dtos.add(new PlaceDTO("ChIJgyOEeT6Z4jAR79gKkiuv270", "จุดถ่ายภาพพระใหญ่วัดปากน้ำ", 13.7220334, 100.4717178, "แขวงตลาดพลู กรุงเทพฯ",
                    "https://places.googleapis.com/v1/places/ChIJgyOEeT6Z4jAR79gKkiuv270/photos/ATCDNfXVfK0UKU-SppzNww2SIsI3gDbessxZGzs4kn9EAp7aS7ga5C8VGOLntFdkzvwNmiWceCuvjhZaw6GCbz7pm9dbcLMU6t_wg5B3nKvNQXoql_-DXgHIUc1f6tDXp3hmAgeirrVy-J-gpp4moxg84QppNEICYcMlmNmLXMyzXV8IXfgF5JLxOOvWjov38NN6M1j1VU6Wk-cbmKPZSlt9Gn2J5mjnrJTnGOZMzFV3xAp1rSgTtZSsZllS0vWFIl8bf1BaCokjxl59q9G7rEk8RABNGCOGkVCb1gEwoVwFD_NBfKxhf7ftxVKxam653KVTtocKnNM7_lTZnus1XL7M_Hvt0XSZguLIudDEjQFDRiC_lVsFnNwZSGri1muFI240QtASVloX_miOkOIv6Xm0bZ8jN1PE2vdaBNkLg3F8PY9iq-dpkNEMFsIfwm8dVg/media?key=" + googleId + "&maxHeightPx=400"));
            dtos.add(new PlaceDTO("ChIJMQZsUcOZ4jARNI3TgUgyyI4", "ท่องเที่ยวตาม BTS", 13.7211058, 100.4768595, "ตลาดพลู",
                    "https://places.googleapis.com/v1/places/ChIJMQZsUcOZ4jARNI3TgUgyyI4/photos/ATCDNfWzbqeJZO1lNWMKG86L5Th9iiV4vULWDPhERWSP-UVoVkBFkYmn4aV9XqMTfMeel4_YI67zV2IYo4M6uEMrJXKSdWTA4b54OClzgWvlN8zYx3aN0K2emZBTHP9OtrSiGaanCZAzCEv-WMaLnslFY5H5Lf7C8oyl-3YTKuRvaxz2BXFD-j219YHY1E3hSdGNcszLX1QUvWGVZV68t6uTGHzZHCHLPcobWEYoKIclk2QQaC17flQ1B8g4oQBesiN3lny8NeSALJWMApEJy3_1Po1f938wpUNtqKU9vg3he7INVw76SBlc3sjP1mdYSV6Q3OiNGxcgz5NTsQLsvlcoGUV-rdptdBOCI771E5ZqG2YDpjbU6vf5Ybtnx8mYXogLyoagIE21kyTWYpaxc4C7GXo3q7vSeh_g7Gxd559RAieUDCho5mD2e3jcIN1hEY8x/media?key=" + googleId + "&maxHeightPx=400"));
            dtos.add(new PlaceDTO("ChIJN1kUQ1yc4jARjpGEPYyF0S0", "อุทยานผีเสื้อและแมลง", 13.8095512, 100.5549011, "จตุจักร", "" +
                    "https://places.googleapis.com/v1/places/ChIJN1kUQ1yc4jARjpGEPYyF0S0/photos/ATCDNfV84wTPNDaGeRgT-WhOZQBrlDtqD549X-rn-DxhAj4zehvX0sM4n-NDv9GwUkh14EJuRRjnrVtuY4BVVfqjivnNkTLXCNORpxx5W3AO31y6MF9KangjirMOkIFPI2OZooL9KX267Q3EGrP4wYteGvZY43fDS-ybJlwgH2-xrEJJ1Miv64zpTiUSBKXhS6eF5FL5NS2I2sGaiuSjgCme1BQo1XTdRTliaJAVGOeryGii6WAF5xXpI9xvkNzR3V6tf2zar6YGhjsIZRLk_tS6hWauUTdvnwT7tHFRQ-qGyqfvFitiYJriL9MFwKnzgoPXlcgt5pmFR4BusaVxUiWQFo_PFFFHDcc6OSHVrSlWgBkJAPeNKCC8ZRMyImCOKXqZoGzCsotUv1yWZL_syFGHefsYT_LkAlaCRR3QgPgvBlmcYg/media?key=" + googleId + "&maxHeightPx=400"));
            dtos.add(new PlaceDTO("ChIJG7BL7Saf4jARNmn5AQiyAaw", "สวนลุมพินี", 13.7314281, 100.5416984, "ปทุมวัน",
                    "https://places.googleapis.com/v1/places/ChIJG7BL7Saf4jARNmn5AQiyAaw/photos/ATCDNfXRt-RIqVCIBsseRmBQHXxzixBbnbExGQ7KVz8v-2ubOvviljD9TSpvPMLzfMfanW__9EGXNZvMy5lPWenJgSLHEigRprQ8u73tmDT9sOuKu-eBwNcpqSgTEiek2OItbphsfrS40S2ap3bdAu8ZZjMBF9gafPMIda6Vfo00_uEuIgP8uyI73VePQVUqSk_Z0TWFEGbkk6xgGKXVeAMaybAv2Y5oy2K4GI-AXsNo1Rj4C7gvKVzgPcjqq0lbBcwP5wrNTx4zndhpCYj8A6F74fxSXR9YPHctTh4PqsjzVZsQkotUmDJ1DwGE6SFGij3pTmOH65YeXUUmd2bbTzohup235Akm4vwSWLIjDKCVo2c5rmiIoEePF1gostIqWOJQ9RwbITHz144i3lIV5N4Kxoxbr8dz8-XrmAnfG4unDYUwTVOI/media?key=" + googleId + "&maxHeightPx=400"));
            dtos.add(new PlaceDTO("ChIJP-AmtpuZ4jAR5dOeFP8pkdo", "สถานที่ถ่ายรูป พระธรรมกายเทพมงคล", 13.7232028, 100.480732, "บางกอกใหญ่",
                    "https://places.googleapis.com/v1/places/ChIJP-AmtpuZ4jAR5dOeFP8pkdo/photos/ATCDNfVB6M2YIL6TBR8ZaYaCVqK1chEkKy3BwAHDEid9rox9c4guVw888kk6gm3K2KZfu6eUVcBpM4l4xOrL1Znxm9QIervQf7L6slOig7BIDHADpxMZ-U_mSzd7ehZPB2a4F7wHp3UPTEkENk0xvW2y3bbH-gZ2rqH18ECsxGwDYdnohbWuOx4KS5Jf9RZYz_4cfyEmPGtVaCFTPEo47DMoOgKSv-yrYi5GM81I2gJlrnk_5ZOA5wGE1Ewkpgt-20L_3OSUj1YClpr7CI3zACTfjLQmGJRJaGwzshNL7pX77_Q_IDgytbn9XiF1Ed2xHE5B8LsVUjce3SCx9d49Q8u5rowYzTIifiPkdSAzH85ZoWrn3TRqr3NO1oHmlNiHVnGyG5eli5xl74H_9ss_nxWCv9KtMSsot6LhBYR5qhU1MN-twA/media?key=" + googleId + "&maxHeightPx=400"));
            dtos.add(new PlaceDTO("ChIJS2EUfkWb4jAR0jmfCeUCfeE", "อุทยานมกุฏรมยสราญ", 13.8610342, 100.515651, "นนทบุรี",
                    "https://places.googleapis.com/v1/places/ChIJS2EUfkWb4jAR0jmfCeUCfeE/photos/ATCDNfX_wDs4lTxSez77i_6DCKY-Ohd9Mpm0wtsTVH1PnJo7Xj8lCpIxnTV7efDEdqyrJ5ABh341bS4ZSmY1f4RslijS3nZq4wg3jPLZ78DQ6eTPle05vxEX2_D9j8cNrBEkQKAfmEaCez4EN3xiDaqThxBMuXuGtPoaDhjHd6x1Vsl3OmfZ52Eh3i60R5pdr4bbMBilyuLTw0yr5-EZlzwE5v3JkNCoxHA96hIknzRbupgN3iI8ltWunEu5eKdQbkI1xa8HAx08-mr8GO_jJoRsLDQv6e5c4JbcK5AxS8a3HDDq0nGthlCNey5l8XD5la2A9kABYhYqJq-5hmpOIhlLkE483hnzESYeIjZCEptnaMUACFPwxFxlIifYHAuuj8OCp35q_l_L6ehD5odbcYJxDoe1pHpeN8xVtqR7rvKmxea8OXn6sJeUwr9Lio8M8A/media?key=" + googleId + "&maxHeightPx=400"));
        }

        // ---------------------------------------------------------
        // 2. ชุดข้อมูลโหมด DISTANCE (Me vs Partner)
        // ---------------------------------------------------------
        else if ("DISTANCE".equalsIgnoreCase(mode)) {
            if ("Partner".equalsIgnoreCase(userTarget)) {
                // --- ข้อมูลฝั่ง PARTNER (อัปเดต Image URL ครบ 10 ที่) ---
                dtos.add(new PlaceDTO("ChIJAcuELQ2Z4jAR3q0DmU_NKkQ", "พิพิธภัณฑสถานแห่งชาติ หอศิลป", 13.7590737, 100.4939671, "เขตพระนคร กรุงเทพฯ",
                        "https://places.googleapis.com/v1/places/ChIJAcuELQ2Z4jAR3q0DmU_NKkQ/photos/ATCDNfX31eFX7_vYRBgjvtHZHXomWzxcDQIlPpewTwMiPcz6J_i4nclHGTqaUUo4aj8aEjmnC71v3wLp7sGwItHvHhevE97h4wMGTKMoiFpOS4x2_nItnyx2HGbCnMXXZZPYqP7-cieKp548piCwVeBEQ5NrCoG54BtwsLgeHXURVZpGpA__AZabBjFeJ9dOwDGvu_PzcD2E8bOoXf1qtSNj83chG_homrn0IiY0nu88UtPnZtiks0a6Hx0Ia_Xf2PuXnc4acQcEo1s86A3KSSDOf2a4btuIMe_XxrOAk6-qJp7uZHDxoo-b4XS92M2LFSE3d3Q5OYyIzR04vHCa_nPOfJnbj7guvJFiJOXJ7PkJgttxu6hmjAYiVYAXkQKX1oPwsSWkdVSr6KvSBHQPLyRpk6y_oiikQwk3d64hCIbRffBT2iuAsQAyVVdcTwN7rAFX/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJ44kOaU-b4jARG9qpD5jqFWg", "พิพิธภัณฑ์ของเล่น ตูนนี่ ประเทศไทย", 13.9347659, 100.5617251, "ปากเกร็ด นนทบุรี",
                        "https://places.googleapis.com/v1/places/ChIJ44kOaU-b4jARG9qpD5jqFWg/photos/ATCDNfX4tgQzcDv7af2SWDSIFWWA2-uk-LFIJMunGLTulD0Bg0QxyHJ_HHt1OcFOOwv73FDV4G4gW0mBD791Dmc5_OA42EI-uVbj1g4TQmiRjjXVaaHAxbSC-uGoUKzFQ6hJpAvNjLg9oMm35Bgonh5SPpHHiHs36rRt6_Hc3d-eLCGkhtU6cs-UQ137CzdX-WCaUr_f0Teko5pTRlqVmHBCX76oGDhDJeggw39SdZUFUraDRWzd6t1tPsdlZ6lEzIxA9_u43cycR_mujH7lK3q7upVOjv2XaZREbOY2ksQBOywQjQ_-p_O31WzJ4lvaCsrLHM--nlabEvK2jhFbFiWI0vbzOhp0bgNX5VwOYn5ePpujAb8No6N15Ps2NWFETHZarhK8zHmjYldkbFrqdeGzvXua4Z6Qe6hL3UCMfMqX0Qaco2U/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJGS-WqpCd4jARWEwGhDbBEfs", "จุดชมวิว", 13.8406145, 100.5735453, "จตุจักร กรุงเทพฯ", null));

                dtos.add(new PlaceDTO("ChIJ9ZMumAeZ4jAR4BMuyRuPWNc", "สวนลอยฟ้าเจ้าพระยา", 13.7390161, 100.4984869, "สะพานพระปกเกล้า",
                        "https://places.googleapis.com/v1/places/ChIJ9ZMumAeZ4jAR4BMuyRuPWNc/photos/ATCDNfVumEnG1etq74gTeSvYnElLVj0m8m_O8s1drY3uIuqmj5jhq1TowoTWGfgrilY8n8v8JeEss_vX3_ojzP29qpRGKmUDZ6H1fuVX925PrvEb1fhkH5A2UmXOjl2-ML_XxhRTTmvyF4gnr3P4RNhIZA9FR98qG0iPfHbLMwu13WMdL26ZkJwSfTS8JXCqMnfOyD-w5fPnaWHxWuElh78zpueXp9-P2iEwTfgl7g9_IL93_Z3_V9tAUu-MvusFgf0hWcsStnhqTMbDJ0zkH1w4sfymV_gYnph7ptoL6g7MRtjwAGbNEGGMYRfPk-_WJVjO26F8VfmLgRAS2gvbU92kv6FArCAp05cQFdvglLo87i_ibMrs7vGLtta7ZIkDcGQHLDKE2TWH2dNFIgohs5gYGPq9WQi3iVGyvsT9N7aHm0vA6aOpPpNSTp3CjMPsIT9u/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJNyfPISjJ4jARoBzjDlUwUMo", "สะพานเชื่อมฟ้ากับทะเล", 13.4579171, 100.187235, "สมุทรสาคร",
                        "https://places.googleapis.com/v1/places/ChIJNyfPISjJ4jARoBzjDlUwUMo/photos/ATCDNfXducgR3-Mx348hfrtDfYUrubev_8hPuggU_Zb4xW4I_7yCyiXHX3b6lb4ao54lcNZZ4a7iV7HioYg-E8Fa5Rp3hpBmq8zk1AQ1C6_EgE9Qd2HE7shOK8NsN2Kjm3Qlu_0YH06VXBs1r_AsplFQ9V4CQB7r93V2c6Hu7TY9Bi4LKc95wViRSxEZCxBGyEqZA5wqyuuOAjg_OFGvosv8sJ38JSQIrY2mfxl9d7nJMhFLm1arn5nU638bMc5S0tJC38UYeLu-j44MR_oG6vAbcpesYttIQxLbhR8k8DYuiAITvS0HAiNC2tEtEmdUv1KY9a8BE4eEktOUHuK4KNxbUZH5B7gNXklCTiB8dq0Vh1wcwiYO8GbSeSAlK0-YLouapMhTQ0NJuQ2etQJyc3vOG6zYOeIqBZoI6VgB0lIs71ATUjrlqGncecVVY6-kIA/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJS2EUfkWb4jAR0jmfCeUCfeE", "อุทยานมกุฏรมยสราญ (สวนศาลากลาง นนทบุรี)", 13.8610342, 100.515651, "นนทบุรี",
                        "https://places.googleapis.com/v1/places/ChIJS2EUfkWb4jAR0jmfCeUCfeE/photos/ATCDNfXvbzxdD5gTCEqs_LKasla-HG7EVxMkr1flWPjYgHADx8VeyCTQoiW6GG-mZjY33Dx_oQxU03cxTaGmgRaIohrV53Ax3TBPN1l_z88jginuWmJE_U5hASjMp3eVGOLYONPOfZOV4LcqqlwYV0YpLfWY-WDBtPqBfp9fWv2kI2SZQUlT8MvfBOueNFSL_Gfzi7A1RvTsHHzHyNMLRhZaGUFaHJEE-WwP3neNnWcu8BxwmSZlUESiSnpecKqtG2N6QXOZ8O-KNhPKhlXQfwAaDlmUUhUfiY2DXEmtEBenNovAFtuICLT5q9NyFUoQTHgr9SZ6sA4NDbApgJ1PwnfHT1_mftvrHr0L48JSyv1qWkJaEXir51kdvCTFAuvyboj6RUJxsEN59eiVBopyhMx8Ur2PqRQf7PlZn3MqRjcmjSPHtagrgx0K_aZ2xHFyXw/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJTw-JsUKc4jAREpXc3JmuyAE", "สวนวชิรเบญจทัศ", 13.81107, 100.5536575, "จตุจักร กรุงเทพฯ",
                        "https://places.googleapis.com/v1/places/ChIJTw-JsUKc4jAREpXc3JmuyAE/photos/ATCDNfW0SzpEQl0LZAuGwbAGyoS5h1RUCaKMxKFX5dm7v1DL3yFUpw3JSrXE7KrkZlRuid3Tgjt_-kSkhtK9aWr8EV45OuDCIu23Sp70bnnksLzUekXUmbiYJ35hErK2VYIco-PWoVNByPLR5gIcOoI_ljaew7pjm88Qx_paR2lUYb87fGRhqz7Ib3VeTad5rvnOKod6Dr9Eazww4UijMWuqybZo_105BEkCX2wdH31_T6y-nOHrbtE2L9saf-f4XELMEo5B2K3VlGTRSaIwZAGKG4eZ2KM5siE16qysgHUHNji10sv9x7mfbQDxjs9P2Pidh2JrAQqqfSMQasMColmggVxEy_LblraHqdurf9hO3VNz6uyajKyau-LeQ0QZ-wKN-wL8Z1cFs1fOgqz74ewVY7vCf3vStDdzCcVV5JKPytw/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJmfMfvBuf4jAR9rugvZd5Lyc", "สวนเบญจกิติ", 13.7270759, 100.5598237, "คลองเตย กรุงเทพฯ",
                        "https://places.googleapis.com/v1/places/ChIJmfMfvBuf4jAR9rugvZd5Lyc/photos/ATCDNfX-FbbmkUWuTQIQp8CpLucQOQ1nT7bP47pC8MPHu7yYR6k043fovIvvfW2cGQtphb3opD33Ko2-gjF8P6qLIhHTMcBFKtP4p5b5a7Hwas9WOOidRHdee-DSVLu82UwSqwVLgZxvmzlQmP51-RoIJJgMVp2gxqZ5liNh1MsnO16q16KFPgtm2ZhN7TI-qiZ0Ijb-ZUMVhLJuLzTb6fcw1k08QHgmMK7oAepSKFr4i1u73BkuvOCUdRrLfMPu6yKwRH7OUA2CWeRfzViTNSAmWU7XOV7bIPEzVhoQG-JPlnZIDUjxy2uVZ6tRXl-f2Qp0QBXvSzX_pNksf-MrYC3n4ql-gqXDi2Gvpecab5LOaOzz0oam7XYfHrG1CY52qUEmoXpMG9q5MbPgmIxpFYsHaZhvzfXbU9OkpQBM-2wAG-8Hy14/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJucPrsaC_4jAR4f9GJfSFOh0", "farmthajeen", 13.6688554, 100.2643184, "กระทุ่มแบน สมุทรสาคร", null));

                dtos.add(new PlaceDTO("ChIJMZ8BYQCZ4jARA59FzwHa14Y", "เทียว", 13.7054214, 100.5030312, "บางคอแหลม กรุงเทพฯ", null));
            } else {
                // --- ข้อมูลฝั่ง ME (อัปเดต Image URL และพิกัดให้ครบ 10 ที่) ---
                dtos.add(new PlaceDTO("ChIJ8094I79tHTER1xbklTOXJTA", "ฮาราจูกุ ไทยแลนด์", 13.8085551, 100.9228937, "หนองจอก กรุงเทพฯ",
                        "https://places.googleapis.com/v1/places/ChIJ8094I79tHTER1xbklTOXJTA/photos/ATCDNfVA5dgBJG6-vvWNJ3wAd-PT3mLhW8VT7yuTs7onM-n42xcQEMC022_a7YME8QluLVPZqJW9MVGzkjH_wCeJWvVIGkdp1IqpiCfBll2unTRCY2yFEn6oF9qP21F7j5KXBtBeAUVlTE5oPENgthYwkx9s2BTBV5h0OWxxQwnrZJth55Y-8zaASIQXbn1p2u6xKpokotSDviA0uxjEGXV2fLkh4KVGzNdD0bEpYmn8WMsXMI4yvKIvzWvYvmMm6CLS7T5O7P6lObDj3psxUa44EhAJX5FYfAyPxHk81He8LkCcIj5e1lcvfBwgoXTuMa3ZWR6M3IPGS-dceSfs2r5vM7uNngYdCLpdl4GUdtnbu12EvBAtZwmCKucNSj3E1zRf3WfcsyuI-D7HXarAx2guCBVKUCqsjkiv7m6N9hAqrR68_xw/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJo4QC7QKT4jARyOZXOngWrjI", "เดอะศาลายา เลเชอร์ ปาร์ค", 13.8037538, 100.3203697, "พุทธมณฑล นครปฐม",
                        "https://places.googleapis.com/v1/places/ChIJo4QC7QKT4jARyOZXOngWrjI/photos/ATCDNfV9ANt3jMCqyE_HGbIewC6aqlXSGTPmAKctMWW9u1k7q4ol7EI8_ffE_4cbtQ3TLzhRQUhFgdcuhMYD8FUCKlPBtdj_yWk9JT2byLII0_pm7RgNbpnph2ziWc9i1QY65SlzwF2H8cNJN9gkD4q2sM7do7QzVwUNEuc7g7wa-vcuAnJJZcDaijDpM28XmZGM_UumPUwZWdxHV6OUCKiTSSjGbOltcIvVdNPh9MSrDtfdCEVg8ZLxyNQiUMw-8euf64YrNpRqIYZm-DRA6I24pDEIdcSzvm-TdHOyRUk3vuOWVw/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJ-cXu5mKf4jARyij2RuZMlw8", "คลองผีหลอก", 13.6995726, 100.5534558, "พระประแดง สมุทรปราการ",
                        "https://places.googleapis.com/v1/places/ChIJ-cXu5mKf4jARyij2RuZMlw8/photos/ATCDNfXKclZvFe9OhTCBb-la62gMep-Fyd8ozv7xqn7vF6O9BPobP1LKCLqWiQDQAATDfUMp1G4P3P130PWyaePER1iHgVjenDbmcgojEP5r6unh27UoRPO1Fu8DB6XSgadUHhfaHqe-UPAS_BeRm6WyXYFaT6V2OiVR5DW90Q73ngoIbUyJ61mzy4kr7hwDnzxaFECiKF26vCdqtdrk7pSHldSCRmArqMyhySnmgks-GKBqSDBuZ4AExa4VnDeMn6nhT6d6fJxMZZxhgWNHvmhgxrSTACBWddCVPNC6zJZ5VWSpAEII9KdAk9zSGSdXnBjAoVW_V-KqiVUTjQQwsgYSM4u69IfBiwMtMtCQOfWJ_Kh2AZ1WZxbcYvbxnenWl0YIGum2w8IRs1fT_9PxIt5kD4aLG9MtfwABjaQmRI0ICnE/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJg7ex0AOh4jARPCFyWecPQiM", "ชุมชนท่องเที่ยวพระประแดง", 13.6607278, 100.5358313, "สมุทรปราการ", null));

                dtos.add(new PlaceDTO("ChIJTw-JsUKc4jAREpXc3JmuyAE", "สวนวชิรเบญจทัศ", 13.81107, 100.5536575, "จตุจักร กรุงเทพฯ",
                        "https://places.googleapis.com/v1/places/ChIJTw-JsUKc4jAREpXc3JmuyAE/photos/ATCDNfWKplKoOlmjuAq9rrS0i_02KBoT7bps5JurMX2_3U4x02gPYXGUZsoU02o0Dxr4fZtugmQI6ZW3VvRNmkT61R7pafoR6G87Ag8Cf37cfzZvEDwbg6yKlUZgcqoxzeTsjEF7J090KZPo50pDWLTuLSfssv2ecQhkG_0DyyLen-X2HAN6hhZSz-t0T2o6nZmnHfFcYXYICyCJfnqOtFTwfrv9NZm9B7gNHMsE4X-0Ei9bWaaA1g0oLYvWb9DG5FaFpJbmQXmBj9l4LgSFJkGfulM59y1o76TlJbEuZAtMg5BI6IwYkjwh5htkXLjwrx8pTZsBDzU_bYhiT1trWw1pTOgTBKQEpIAmE5lIyVlHOAzpLAL2Dt_djrDVEHdB5ldYGz2kJhDylnO6nopzGD_i_skH2bA4gSaMqfnQcLfAQf4/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJjbUVz4yh4jARE4lcukLeMJY", "สวนสุขภาพลัดโพธิ์", 13.6653388, 100.5375569, "พระประแดง สมุทรปราการ",
                        "https://places.googleapis.com/v1/places/ChIJjbUVz4yh4jARE4lcukLeMJY/photos/ATCDNfVqGH-QTora-98tJjTF7MQH3wGW5OQR_RulFm00by_iGA9HSV0EMB2TS7yVoubeNBG_Jfi16xOPjlMYPZi-FfB-i0UMMxE5pdyDeOYJHDnEYMIBgeRO_7bEEnTc7fJhh2O41A1r173ncifhB1_7kkT-K7fhHUKb4ghCN3x11hnH4Hzy1v8yPOvtlQl_usAI8QufBa2FrRbzAsZVJGVdRxox5wFMsWutkZ2DY5iL5Aujeo1IFVtcn3_vgMlV7GHxpEG_ATT0zJ3e8x3ulXpoh4FhF0J__vvvm6asf4sMwibPcYcYkcbGQstNscCNq1lH7XdFOFmTmpDm68eeDKU8vDhMJNXqkOdZOQ9m-DrS-DQb9HHRK15igtfely-LWp226O7r8Riil9zVVXHPq56mJVYI2VKJ1afv-UR44_E82xslSGA/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJF6uVAzt9HTEROKM0WKZMU7M", "บ้านศิลปินคลองบางหลวง", 13.7313154, 100.4632197, "ภาษีเจริญ กรุงเทพฯ",
                        "https://places.googleapis.com/v1/places/ChIJF6uVAzt9HTEROKM0WKZMU7M/photos/ATCDNfUnG3300UsKOTIidE_3C4Qh3Vq3AR8BLSo4bfUzn_2QQIOo_cMhAdi8aBnXNtXo0tZ98E5rLeMv78VkmZ4i1wqQTi2OUE7X7Heg3xPrvcx94FWuIHxLSo0mQ6M0tKJfqwrP9M6o6ma_sLqqU0xOcFuueUyFk6ckyFP8WyX0ykB0lgphPCi21tv3XFjtdb_dfNBgsH_etFG8Xq4qzm9iZ3h7iglGTNyjbyzPuSZWd1gR180QBk0jmJpb1-shiyMse9BuVN9lkTAUaq4_Uxbl4XGUx_Gl5Ued9-RvYF3VQ_3lSw/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJWw09Q4hYHTERvzMOKrUzEWM", "สวนแห่งเทพเจ้า (043)", 13.5495967, 100.6325531, "ยานนาวา กรุงเทพฯ",
                        "https://places.googleapis.com/v1/places/ChIJWw09Q4hYHTERvzMOKrUzEWM/photos/ATCDNfWzbY0xLfeDH4eYevy0Ep4IzNW_7DxERELiWJytdHCjVzSivm2SnSbJpq2ih6geXbxeL8aot7dnubGn1OzPdLe2wCiUEtMDBSPftgXVfgdk0G4Dp2wfF8zm2hmC3BMa8miLeWLEgrbZ83ude9BGF0ZOCN8nDxTI3iwvpzLKbOXtV6Rua63KibxUHukp0Qf0iLYrb5yYLMIIUFP3hj5YDRD7Xy5qZnOvtQkvDpIkdWCj3r-VYHQz6VZ_AEHyURjEEFlndBT8V1CqrQBiFnGoc-BmonVL42W-STk2KDlN5FoNji8ZQE0Kia83cT7nx_PU_o9X2t1f5rTywsvOar6OvwE9U5RHOUJXtcgydDZkViAoR_WZS4edk5RFHML_48nEQ4OHSQ1_WVQooh5OyM3-8yckWwh6fqL5WZeb-qHCgm1DvQ/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJmfMfvBuf4jAR9rugvZd5Lyc", "สวนเบญจกิติ", 13.7270759, 100.5598237, "คลองเตย กรุงเทพฯ",
                        "https://places.googleapis.com/v1/places/ChIJmfMfvBuf4jAR9rugvZd5Lyc/photos/ATCDNfWuvJVmEToFVlZKrGRba-6S7aXjRrZzZJR_SRYYcPks8EKAZhO5t6fc_8dMQib9Sxx2zXxGGuM7Ui_AF5rfYF0Lpnc20IM3eWTwxV-OI6K9kuAjWyuC84wrKFjvntM9wkGvV69jKn4XD_3rMYG67FsCTfmRkXdZe2SaJSBiSqcHzRoJ9912QpWcEmQpox5IlxzJccRFCs6l2aXSPRJQC5RqILI5zAnd2f_u3PSdYqZYYFc8F-6ezdwYzQciT9QuzY_TJ-D7PrzFxfEQZuC_vhoN68sJNFWGYMjudgocSqihqKqqexGqJQoJjeARkmtBy3FVUAFUhIyHfB3oWzrGaCz_6eyA2vtB5c8WFjEDIiCUGuN_EVhHwSyTTh6hgNjXlOG0002zbb3BMmYeqA7M-ZNmztNODww9X7qU1_RM4WCkZ6U/media?key=" + googleId + "&maxHeightPx=400"));

                dtos.add(new PlaceDTO("ChIJ4cA9FABZHTERQJgBBN3-2tg", "The garden of the God", 13.5489222, 100.6327312, "สมุทรปราการ",
                        "https://places.googleapis.com/v1/places/ChIJ4cA9FABZHTERQJgBBN3-2tg/photos/ATCDNfXnrJSzDOYjhqTQdWB208qDXWuvBiGgr1uFpGWigQqstKIEQ7POqL9t9z6Ij1_cHoxk09LjFThsmHvAHmvP8aaQPuL-7Ba-iPMzG3OCG_RR_pgje-thn18HkZ0gxQzptyyLaw3DImfuwBs2oij5tEnexrB11s4smjWn-ypMOWO6WOI0P3yjUI3U2WZF7NFKpAzOs2Dq1Bp67_ywjozjX2fb3qDjJR_9G_Fn_5YHnPYPsrFCcrygCIk2gC4LyoHRx8-CcvpSuyhL8iJxaNZ8Vx0EC0cLvM2-UOsC38TQX5GEEf4SYZ5piR9tBno6eZqPn6zJP1F0hl2bqOtyBnLijXFI5pZ2in2Cm-Yw41XC8fEqBYdLsQnNVLAUaNsXIr7A3kQqYh-HwhxWFnOarky_4p2bQriUwTmk9Ye4v1g-VQV-pXHV7NLSoUGYQgyBeg/media?key=" + googleId + "&maxHeightPx=400"));
            }
        }

        return dtos;
    }

    private List<PlaceDTO> parsePlaces(JsonNode root) {
        List<PlaceDTO> dtos = new ArrayList<>();
        JsonNode places = root.path("places");

        if (places.isArray()) {
            for (JsonNode place : places) {
                String photoUrl = null; // ตั้งต้นเป็น null เผื่อสถานที่นั้นไม่มีรูป
                JsonNode photos = place.path("photos");

                if (photos.isArray() && !photos.isEmpty()) {
                    // ดึงชื่อ Resource มา (เช่น places/ChIJ.../photos/...)
                    String photoName = photos.get(0).path("name").asText();

                    // นำมาต่อเป็น URL ที่ใช้งานได้จริง
                    photoUrl = "https://places.googleapis.com/v1/" + photoName +
                            "/media?key=" + googleId + "&maxHeightPx=400";
                }

                if (photoUrl == null) continue;
                dtos.add(new PlaceDTO(
                        place.path("id").asText(),
                        place.path("displayName").path("text").asText(),
                        place.path("location").path("latitude").asDouble(),
                        place.path("location").path("longitude").asDouble(),
                        place.path("formattedAddress").asText(),
                        photoUrl
                ));
            }
        }
        return dtos;
    }

    public Coordinates calculateMidpoint(UserLocation user1, UserLocation user2) {
        double midLat = (user1.getLatitude().doubleValue() + user2.getLatitude().doubleValue()) / 2;
        double midLng = (user1.getLongitude().doubleValue() + user2.getLongitude().doubleValue()) / 2;

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

    public SpinStatusResponse checkSpinStatus(String roomId) {
        Integer matchId = Integer.valueOf(roomId);

        Optional<Appointment> appointmentOpt = appointmentRepository.findFirstByMatch_IdOrderByCreatedAtDesc(matchId);

        Optional<PlaceConfirmation> pendingConfirm = placeConfirmationRepository
                .findFirstByMatchAndStatusOrderByConfirmIdDesc(matchId, ConfirmationStatus.PENDING);

        if (pendingConfirm.isPresent()) {
            return new SpinStatusResponse(false, 0);
        }

        ZoneId bangkokZone = ZoneId.of("Asia/Bangkok");
        ZonedDateTime nowThai = ZonedDateTime.now(bangkokZone);

        Optional<RelationshipStats> relationshipStats = relationshipStatsRepository.findByRoomId(Integer.valueOf(roomId));
        int score = (relationshipStats.get().getScore() != null) ? relationshipStats.get().getScore() : 0;

        if (appointmentOpt.isPresent()) {
            Appointment latest = appointmentOpt.get();

            if (latest.getStatus() == AppointmentStatus.PLACE_SELECTED ||
                    latest.getStatus() == AppointmentStatus.SCHEDULED) {
                return new SpinStatusResponse(false, 0);
            }

            LocalDateTime baseTime = latest.getDateTime() != null
                    ? latest.getDateTime()
                    : latest.getUpdatedAt();

            int cooldownDays;
            if (latest.getStatus() == AppointmentStatus.CANCELLED) {
                cooldownDays = 1;
            } else if (latest.getStatus() == AppointmentStatus.COMPLETED) {
                if (score >= 400) {
                    cooldownDays = 1;
                } else if (score >= 300) {
                    cooldownDays = 3;
                } else {
                    cooldownDays = 7;
                }
            } else {
                cooldownDays = 0;
            }

            ZonedDateTime lastUpdateThai = baseTime.atZone(bangkokZone);
            ZonedDateTime unlockTime = lastUpdateThai.plusDays(cooldownDays);

            if (nowThai.isBefore(unlockTime)) {
                // ส่งค่าเป็น Milliseconds (Epoch) ซึ่งเป็นค่าสากล Flutter จะรับไปแปลงต่อได้แม่นยำ
                return new SpinStatusResponse(
                        false,
                        unlockTime.toInstant().toEpochMilli()
                );
            }
        }

        return new SpinStatusResponse(true, 0);
    }

    public void deleteAppointmentAfterCooldown(String roomId, String accessToken) {
        User user = extractToken(accessToken);

        Match match = matchRepository.findById(Integer.valueOf(roomId))
                .orElseThrow(() -> new NotFoundException("Match not found with id: " + roomId));

        if (!Objects.equals(user.getUserId(), match.getUserId1().getUserId()) &&
                !Objects.equals(user.getUserId(), match.getUserId2().getUserId())) {
            throw new ForbiddenAccessException("Forbidden: cannot access another user's data");
        }

        Appointment latest = appointmentRepository
                .findFirstByMatch_IdOrderByCreatedAtDesc(Integer.valueOf(roomId))
                .orElseThrow(() -> new NotFoundException("Appointment not found for room: " + roomId));

        LocalDateTime baseTime = latest.getDateTime() != null
                ? latest.getDateTime()
                : latest.getUpdatedAt();

        ZoneId bangkokZone = ZoneId.of("Asia/Bangkok");
        ZonedDateTime nowThai = ZonedDateTime.now(bangkokZone);

        Optional<RelationshipStats> relationshipStats = relationshipStatsRepository.findByRoomId(Integer.valueOf(roomId));
        int score = (relationshipStats.isPresent() && relationshipStats.get().getScore() != null)
                ? relationshipStats.get().getScore() : 0;

        int cooldownDays = 0;
        if (latest.getStatus() == AppointmentStatus.CANCELLED) {
            cooldownDays = 1;
        } else if (latest.getStatus() == AppointmentStatus.COMPLETED) {
            if (score >= 400) cooldownDays = 1;
            else if (score >= 300) cooldownDays = 3;
            else cooldownDays = 7;
        }

        ZonedDateTime unlockTime = baseTime.atZone(bangkokZone).plusDays(cooldownDays);
        if (nowThai.isBefore(unlockTime)) {
            throw new LockedException("Cooldown has not ended yet");
        }

        if (latest.getStatus() ==  AppointmentStatus.SCHEDULED || latest.getStatus() ==  AppointmentStatus.PLACE_SELECTED) {
            throw new LockedException("Cannot delete active appointment");
        }
        appointmentRepository.delete(latest);
    }

    @Data
    @AllArgsConstructor
    public static class Coordinates {
        private double lat;
        private double lng;
    } 
}

