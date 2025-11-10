package sit.chat2date.cp25ssi2.services;

import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.dto.UserSummaryDto;
import sit.chat2date.cp25ssi2.enums.ActionType;
import sit.chat2date.cp25ssi2.exceiptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceiptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceiptions.ServiceException;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@Service
public class DiscoveryService {

    private static final Map<String, UserSummaryDto> USERS = new HashMap<>();
    private static final Map<String, String> LIKES = new HashMap<>();

    static {
        USERS.put("u_1", new UserSummaryDto("u_1", "08xxxxxxx"));
        USERS.put("u_2", new UserSummaryDto("u_2", "09xxxxxxx"));
        USERS.put("u_3", new UserSummaryDto("u_3", "06xxxxxxx"));
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

    /** @return "match" | "notmatch" */
    public String submitFeedback(String actorUserId, String targetUserId, ActionType action) {
        if (actorUserId == null || targetUserId == null || action == null) {
            throw new BadRequestException("actorUserId/targetUserId/action is required");
        }
        if (!USERS.containsKey(actorUserId)) throw new NotFoundException("actor user not found: " + actorUserId);
        if (!USERS.containsKey(targetUserId)) throw new NotFoundException("target user not found: " + targetUserId);
        if (actorUserId.equals(targetUserId)) throw new BadRequestException("cannot feedback to self");

        try {
            switch (action) {
                case LIKE -> {
                    String likedByTarget = LIKES.get(targetUserId);
                    if (actorUserId.equals(likedByTarget)) return "match";
                    LIKES.put(actorUserId, targetUserId);
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
