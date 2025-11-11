package sit.chat2date.cp25ssi2.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.dto.UserSummaryDto;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.ActionType;
import sit.chat2date.cp25ssi2.exceptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceptions.ServiceException;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

@Service
public class DiscoveryService {

    private static final Map<String, UserSummaryDto> USERS = new HashMap<>();
    private static final Map<String, String> LIKES = new HashMap<>();

    static {
        USERS.put("u_1", new UserSummaryDto("u_1", "08xxxxxxx"));
        USERS.put("u_2", new UserSummaryDto("u_2", "09xxxxxxx"));
        USERS.put("u_3", new UserSummaryDto("u_3", "06xxxxxxx"));
    }

    private final UserRepository userRepository;

    public DiscoveryService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserSummaryDto getCandidate(String userId, int minDistance, int maxDistance) {
        if (minDistance > maxDistance) {
            throw new BadRequestException("minDistance must be <= maxDistance");
        }
        if (!USERS.containsKey(userId)) {
            throw new NotFoundException("user not found: " + userId);
        }
        for (UserSummaryDto u : USERS.values()) {
            if (!Objects.equals(u.getId(), userId)) return u;
        }
        throw new ServiceException("no candidate available");
    }

    /**
     * @return "match" | "notmatch"
     */
    public String submitFeedback(String targetUserId, ActionType action, String accessToken) {
        if (targetUserId == null || action == null) {
            throw new BadRequestException("targetUserId/action is required");
        }
        Optional<User> targetUser = userRepository.findByUserId(targetUserId);
        String jwtToken;
        jwtToken = accessToken.substring(7);
        Optional<User> user;

        DecodedJWT jwt = JWT.decode(jwtToken);
        String sub = jwt.getClaim("sub").asString();
        if (sub.length() == 10) {
            user = userRepository.findByPhoneNumber(sub);
        } else {
            user = userRepository.findByEmail(sub);
        }

        if (targetUser.isEmpty()) throw new NotFoundException("target user not found: " + targetUserId);
        if (user.get().getUserId().equals(targetUserId)) throw new BadRequestException("cannot feedback to self");

        try {
            switch (action) {
                case LIKE -> {
                    String likedByTarget = LIKES.get(targetUserId);
                    if (user.get().getUserId().equals(likedByTarget)) return "match";
                    LIKES.put(user.get().getUserId(), targetUserId);
                    return "notmatch";
                }
                case DISLIKE -> {
                    return "notmatch";
                }
                default -> throw new BadRequestException("unsupported action: " + action);
            }
        } catch (RuntimeException e) {
            throw new ServiceException("internal processing error");
        }
    }
}
