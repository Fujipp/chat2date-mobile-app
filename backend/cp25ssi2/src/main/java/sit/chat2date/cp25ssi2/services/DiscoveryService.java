package sit.chat2date.cp25ssi2.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.dto.FeedbackResponse;
import sit.chat2date.cp25ssi2.dto.UserSummaryDTO;
import sit.chat2date.cp25ssi2.entities.Action;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.dto.*;
import sit.chat2date.cp25ssi2.entities.*;
import sit.chat2date.cp25ssi2.enums.ActionType;
import sit.chat2date.cp25ssi2.exceptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceptions.ServiceException;
import sit.chat2date.cp25ssi2.repositories.*;
import sit.chat2date.cp25ssi2.utils.CompatibilityCalculator;

import java.time.LocalDate;
import java.time.Period;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class DiscoveryService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private  ActionRepository actionRepository;

    @Autowired
    private  MatchRepository matchRepository;

    @Autowired
    private TravelStyleRepository travelStyleRepository;

    @Autowired
    private LifeStyleRepository lifestyleRepository;

    @Autowired
    private InterestRepository interestRepository;

    @Autowired
    private PreferenceMatchRepository preferenceRepository;

    @Autowired
    private UserLocationRepository locationRepository;
    @Autowired
    private CompatibilityCalculator compatibilityCalculator;
    @Autowired
    private UserPhotoRepository userPhotoRepository;
    @Autowired
    private TagRepository tagRepository;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private MatchSocketService matchSocketService;

    public List<DiscoveryResponse> getCandidates(
            String userId,
            int minDistance,
            int maxDistance
    ) {
        int limit = 10;
        System.out.println("pref = " + userId);
        PreferenceMatch pref = preferenceRepository.findByUser_UserId(userId);
        System.out.println("pref = " + pref); // null?

        UserLocation myLocation = locationRepository.findFirstByUser_UserId(userId);

        List<String> userTravelStyles = travelStyleRepository.findTravelStylesByUserId(userId);
        List<String> userLifestyles = lifestyleRepository.findLifeStylesByUserId(userId);
        List<String> userInterests = interestRepository.findInterestsByUserId(userId);

        boolean allUnnecessary =
                "UNNECESSARY".equals(pref.getInterestedTravelStyle().name()) &&
                        "UNNECESSARY".equals(pref.getInterestedLifeStyle().name()) &&
                        "UNNECESSARY".equals(pref.getInterestedInterest().name());

        List<User> candidates;

        if (allUnnecessary) {
            // ไม่ filter attribute อื่นเลย
            candidates = userRepository.findCandidatesBasic(
                    userId,
                    myLocation.getLatitude().doubleValue(),
                    myLocation.getLongtitude().doubleValue(),
                    minDistance,
                    maxDistance,
                    pref.getInterestedAgeMin(),
                    pref.getInterestedAgeMax(),
                    pref.getInterestedGender().name(),
                    limit
            );
        } else {
            // Filter ตาม attribute
            candidates = userRepository.findCandidatesWithPreference(
                    userId,
                    myLocation.getLatitude().doubleValue(),
                    myLocation.getLongtitude().doubleValue(),
                    minDistance,
                    maxDistance,
                    pref.getInterestedAgeMin(),
                    pref.getInterestedAgeMax(),
                    pref.getInterestedGender().name(),
                    pref.getInterestedTravelStyle().name(),
                    pref.getInterestedLifeStyle().name(),
                    pref.getInterestedInterest().name(),
                    userTravelStyles.size(),
                    userLifestyles.size(),
                    userInterests.size(),
                    limit
            );
        }

        // map ไปเป็น DiscoveryResponse พร้อม score และเรียงตาม logic ที่ตอบไว้
        return candidates.stream()
                .map(candidate -> {
                    List<String> candidateTravelStyles = travelStyleRepository.findTravelStylesByUserId(candidate.getUserId());
                    List<String> candidateLifestyles = lifestyleRepository.findLifeStylesByUserId(candidate.getUserId());
                    List<String> candidateInterests = interestRepository.findInterestsByUserId(candidate.getUserId());
                    List<String> candidatePhotos = getPhotoUrls(candidate.getUserId());
                    List<String> candidateTags = tagRepository.findTagsByUserId(candidate.getUserId());

                    double distance = calculateDistance(myLocation, locationRepository.findFirstByUser_UserId(candidate.getUserId()));
                    int score = compatibilityCalculator.calculateCompatibilityWithPreference(
                            userTravelStyles, candidateTravelStyles, pref.getInterestedTravelStyle().name(),
                            userLifestyles, candidateLifestyles, pref.getInterestedLifeStyle().name(),
                            userInterests, candidateInterests, pref.getInterestedInterest().name()
                    );

                    return new DiscoveryResponse(
                            candidate.getUserId(),
                            candidate.getNickname(),
                            calculateAge(candidate.getBirthday()),
                            candidate.getSex().toString(),
                            candidatePhotos,
                            candidateTags,
                            candidateTravelStyles,
                            candidateInterests,
                            candidateLifestyles,
                            distance,
                            score
                    );
                })
                .sorted(Comparator
                        .comparingInt(DiscoveryResponse::getCompatibilityScore).reversed()
                        .thenComparingDouble(DiscoveryResponse::getDistance))
                .collect(Collectors.toList());
    }


    private List<String> getPhotoUrls(String userId) {
        String jsonString = userPhotoRepository.findAttributesJsonByUser_UserId(userId);
        if (jsonString == null || jsonString.isEmpty()) {
            return Collections.emptyList();
        }

        try {
            ObjectMapper objectMapper = new ObjectMapper();
            PhotoDTO photoDTO = objectMapper.readValue(jsonString, PhotoDTO.class);
            return photoDTO.getUrls();
        } catch (Exception e) {  // JsonProcessingException
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    private double calculateDistance(UserLocation loc1, UserLocation loc2) {
        if (loc1 == null || loc2 == null) {
            return 0.0;
        }

        double lat1 = loc1.getLatitude().doubleValue();
        double lon1 = loc1.getLongtitude().doubleValue();
        double lat2 = loc2.getLatitude().doubleValue();
        double lon2 = loc2.getLongtitude().doubleValue();

        // Haversine formula
        final double EARTH_RADIUS_KM = 6371;

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        double distance = EARTH_RADIUS_KM * c;

        // Round to 2 decimal places
        return Math.round(distance * 100.0) / 100.0;
    }

    private int calculateAge(LocalDate birthday) {
        return Period.between(birthday, LocalDate.now()).getYears();
    }

//    // === mock candidate ไว้ก่อน เผื่อ Dev ยังใช้ getCandidate อยู่ ===
//    private static final Map<String, UserSummaryDto> USERS = new HashMap<>();
//    static {
//        USERS.put("u_1", new UserSummaryDto("u_1", "08xxxxxxx"));
//        USERS.put("u_2", new UserSummaryDto("u_2", "09xxxxxxx"));
//        USERS.put("u_3", new UserSummaryDto("u_3", "06xxxxxxx"));
//    }

//    public DiscoveryService(
//            UserRepository userRepository,
//            ActionRepository actionRepository,
//            MatchRepository matchRepository
//    ) {
//        this.userRepository = userRepository;
//        this.actionRepository = actionRepository;
//        this.matchRepository = matchRepository;
//    }

//    // ถ้า Dev ยังใช้ /discovery/distance อยู่ ก็ปล่อยตัวนี้ไว้ก่อนได้
//    public UserSummaryDto getCandidate(String userId, int minDistance, int maxDistance) {
//        if (minDistance > maxDistance) {
//            throw new BadRequestException("minDistance must be <= maxDistance");
//        }
//        if (!USERS.containsKey(userId)) {
//            throw new NotFoundException("user not found: " + userId);
//        }
//        for (UserSummaryDto u : USERS.values()) {
//            if (!Objects.equals(u.getId(), userId)) return u;
//        }
//        throw new ServiceException("no candidate available");
//    }

    /**
     * ใช้ตอน user กด like/dislike
     * - บันทึก action ลง actiontable
     * - ถ้าอีกฝั่งเคยกด LIKE เราไว้ → สร้าง Match ใน matchtable และส่ง matched = true กลับไป
     */
    public FeedbackResponse submitFeedback(String userId,String targetUserId, ActionType action) {
        if (targetUserId == null || action == null) {
            throw new BadRequestException("targetUserId/action is required");
        }

        // 1) หา target user
        User targetUser = userRepository.findByUserId(targetUserId)
                .orElseThrow(() -> new NotFoundException("target user not found: " + targetUserId));

//        // 2) ดึง current user จาก JWT
//        String jwtToken = accessToken.substring(7); // ตัด "Bearer "
//        DecodedJWT jwt = JWT.decode(jwtToken);
//        String sub = jwt.getClaim("sub").asString();
//
//        User currentUser = (sub.length() == 10)
//                ? userRepository.findByPhoneNumber(sub).orElseThrow()
//                : userRepository.findByEmail(sub).orElseThrow();

        User currentUser = userRepository.findUsersByUserId(userId);

        if (currentUser.getUserId().equals(targetUserId)) {
            throw new BadRequestException("cannot feedback to self");
        }

        try {
            // 3) บันทึก Action ทุกครั้งที่มีการ like / dislike
            Action act = new Action();
            act.setUser(currentUser);
            act.setTargetUser(targetUser);
            act.setActionType(action.name()); // "LIKE" หรือ "DISLIKE"
            actionRepository.save(act);

            // 4) ถ้า DISLIKE → จบเลย ยังไงก็ notmatch
            if (action == ActionType.DISLIKE) {
                return new FeedbackResponse(
                        "notmatch",
                        false,
                        targetUserId,
                        targetUser.getFirstname() + " " + targetUser.getLastname()
                );
            }

            // 5) ถ้าเป็น LIKE → เช็คว่าอีกฝั่งเคย LIKE เรามั้ย
            boolean targetLikedMe = actionRepository
                    .existsByUserUserIdAndTargetUserUserIdAndActionType(
                            targetUser.getUserId(),      // เขา
                            currentUser.getUserId(),     // เรา
                            ActionType.LIKE.name()
                    );

            if (targetLikedMe) {
                // 5.1 สร้าง Match ใน matchtable (กัน A-B/B-A ซ้ำด้วยการ sort)
                User u1 = currentUser.getUserId().compareTo(targetUser.getUserId()) < 0
                        ? currentUser : targetUser;
                User u2 = (u1 == currentUser) ? targetUser : currentUser;

                if (!matchRepository.existsByUserId1AndUserId2(u1, u2)) {
                    Match m = new Match();
                    m.setUserId1(u1);
                    m.setUserId2(u2);
                    matchRepository.save(m);
                }

                // ★ 5.2 ยิง push แจ้งเตือนให้ทั้งสองฝั่ง
                try {
                    notificationService.sendMatchNotification(
                            currentUser.getUserId(),
                            targetUser.getNickname()
                    );
                    notificationService.sendMatchNotification(
                            targetUser.getUserId(),
                            currentUser.getNickname()
                    );
                    matchSocketService.broadcastMatch(currentUser, targetUser);
                } catch (Exception e) {
                    System.out.println("[Discovery] Failed to send match notifications: " + e.getMessage());
                }

                // 5.3 ส่ง response ว่า match แล้ว 🎉
                return new FeedbackResponse(
                        "match",
                        true,
                        targetUserId,
                        targetUser.getFirstname() + " " + targetUser.getLastname()
                );
            }

            // 6) ยังไม่ match แค่บันทึก Action ไว้เฉย ๆ
            return new FeedbackResponse(
                    "notmatch",
                    false,
                    targetUserId,
                    targetUser.getFirstname() + " " + targetUser.getLastname()
            );

        } catch (RuntimeException e) {
            throw new ServiceException("internal processing error");
        }
    }
}
