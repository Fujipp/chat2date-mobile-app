package sit.chat2date.cp25ssi2.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.dto.FeedbackResponse;
import sit.chat2date.cp25ssi2.dto.UserSummaryDTO;
import sit.chat2date.cp25ssi2.entities.Action;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.ActionType;
import sit.chat2date.cp25ssi2.exceptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceptions.ServiceException;
import sit.chat2date.cp25ssi2.repositories.ActionRepository;
import sit.chat2date.cp25ssi2.repositories.MatchRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@Service
public class DiscoveryService {

    // === mock candidate ไว้ก่อน เผื่อ Dev ยังใช้ getCandidate อยู่ ===
    private static final Map<String, UserSummaryDTO> USERS = new HashMap<>();
    static {
        USERS.put("u_1", new UserSummaryDTO("u_1", "08xxxxxxx"));
        USERS.put("u_2", new UserSummaryDTO("u_2", "09xxxxxxx"));
        USERS.put("u_3", new UserSummaryDTO("u_3", "06xxxxxxx"));
    }

    private final UserRepository userRepository;
    private final ActionRepository actionRepository;
    private final MatchRepository matchRepository;

    public DiscoveryService(
            UserRepository userRepository,
            ActionRepository actionRepository,
            MatchRepository matchRepository
    ) {
        this.userRepository = userRepository;
        this.actionRepository = actionRepository;
        this.matchRepository = matchRepository;
    }

    // ถ้า Dev ยังใช้ /discovery/distance อยู่ ก็ปล่อยตัวนี้ไว้ก่อนได้
    public UserSummaryDTO getCandidate(String userId, int minDistance, int maxDistance) {
        if (minDistance > maxDistance) {
            throw new BadRequestException("minDistance must be <= maxDistance");
        }
        if (!USERS.containsKey(userId)) {
            throw new NotFoundException("user not found: " + userId);
        }
        for (UserSummaryDTO u : USERS.values()) {
            if (!Objects.equals(u.getId(), userId)) return u;
        }
        throw new ServiceException("no candidate available");
    }

    /**
     * ใช้ตอน user กด like/dislike
     * - บันทึก action ลง actiontable
     * - ถ้าอีกฝั่งเคยกด LIKE เราไว้ → สร้าง Match ใน matchtable และส่ง matched = true กลับไป
     */
    public FeedbackResponse submitFeedback(String targetUserId, ActionType action, String accessToken) {
        if (targetUserId == null || action == null) {
            throw new BadRequestException("targetUserId/action is required");
        }

        // 1) หา target user
        User targetUser = userRepository.findByUserId(targetUserId)
                .orElseThrow(() -> new NotFoundException("target user not found: " + targetUserId));

        // 2) ดึง current user จาก JWT
        String jwtToken = accessToken.substring(7); // ตัด "Bearer "
        DecodedJWT jwt = JWT.decode(jwtToken);
        String sub = jwt.getClaim("sub").asString();

        User currentUser = (sub.length() == 10)
                ? userRepository.findByPhoneNumber(sub).orElseThrow()
                : userRepository.findByEmail(sub).orElseThrow();

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

                // 5.2 ส่ง response ว่า match แล้ว 🎉
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
