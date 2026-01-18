package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sit.chat2date.cp25ssi2.dto.ChatAccessRequest;
import sit.chat2date.cp25ssi2.dto.ChatAccessStatusResponse;
import sit.chat2date.cp25ssi2.entities.ChatAccessLog;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.enums.ChatAccessActionType;
import sit.chat2date.cp25ssi2.exceptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceptions.ConflictException;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.ChatAccessLogRepository;
import sit.chat2date.cp25ssi2.repositories.MatchRepository;
import sit.chat2date.cp25ssi2.repositories.MessageRepository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatAccessService {

    private final ChatAccessLogRepository chatAccessLogRepository;
    private final MatchRepository matchRepository;
    private final MessageRepository messageRepository;
    private final ChatSocketService chatSocketService;

    /**
     * Enter a chat room - update read status
     */
    @Transactional
    public void enterRoom(String userId, ChatAccessRequest request) {
        if (request.getType() != ChatAccessActionType.ENTER) {
            throw new BadRequestException("Invalid action type for enter");
        }

        Integer matchId = Integer.parseInt(request.getRoomId());
        Match match = matchRepository.findByIdAndUserId(matchId, userId)
                .orElseThrow(() -> new NotFoundException("Room not found"));

        if (!match.getUserId1().getUserId().equals(userId) && !match.getUserId2().getUserId().equals(userId)) {
            throw new ForbiddenAccessException("Access denied to this room");
        }

        // Check if user is already in room - 409 CONFLICT
        Optional<ChatAccessLog> latestLog = chatAccessLogRepository.findLatestByRoomIdAndUserId(request.getRoomId(),
                userId);
        if (latestLog.isPresent() && latestLog.get().getActionType() == ChatAccessActionType.ENTER) {
            throw new ConflictException("User is already in the room");
        }

        // Create access log
        ChatAccessLog accessLog = ChatAccessLog.builder()
                .userId(userId)
                .roomId(request.getRoomId())
                .actionType(ChatAccessActionType.ENTER)
                .build();
        chatAccessLogRepository.save(accessLog);

        // Mark messages as read for this user
        messageRepository.markMessagesAsRead(request.getRoomId(), userId);

        // Broadcast status change
        ChatAccessStatusResponse status = getRoomAccessStatus(request.getRoomId());
        chatSocketService.broadcastAccessStatus(request.getRoomId(), status);
    }

    /**
     * Exit a chat room
     */
    @Transactional
    public void exitRoom(String userId, ChatAccessRequest request) {
        if (request.getType() != ChatAccessActionType.EXIT) {
            throw new BadRequestException("Invalid action type for exit");
        }

        Integer matchId = Integer.parseInt(request.getRoomId());
        Match match = matchRepository.findByIdAndUserId(matchId, userId)
                .orElseThrow(() -> new NotFoundException("Room not found"));

        if (!match.getUserId1().getUserId().equals(userId) && !match.getUserId2().getUserId().equals(userId)) {
            throw new ForbiddenAccessException("Access denied to this room");
        }

        // Create access log
        ChatAccessLog accessLog = ChatAccessLog.builder()
                .userId(userId)
                .roomId(request.getRoomId())
                .actionType(ChatAccessActionType.EXIT)
                .build();
        chatAccessLogRepository.save(accessLog);

        // Broadcast status change
        ChatAccessStatusResponse status = getRoomAccessStatus(request.getRoomId());
        chatSocketService.broadcastAccessStatus(request.getRoomId(), status);
    }

    /**
     * Get room access status for all members
     */
    public ChatAccessStatusResponse getRoomAccessStatus(String roomId) {
        Integer matchId = Integer.parseInt(roomId);
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new NotFoundException("Room not found"));

        List<ChatAccessLog> latestLogs = chatAccessLogRepository.findLatestStatusByRoomId(roomId);

        List<ChatAccessStatusResponse.RoomMember> members = List.of(
                match.getUserId1().getUserId(),
                match.getUserId2().getUserId()).stream().map(userId -> {
                    ChatAccessActionType status = latestLogs.stream()
                            .filter(log -> log.getUserId().equals(userId))
                            .findFirst()
                            .map(ChatAccessLog::getActionType)
                            .orElse(ChatAccessActionType.EXIT);

                    return ChatAccessStatusResponse.RoomMember.builder()
                            .userId(userId)
                            .type(status)
                            .build();
                }).collect(Collectors.toList());

        return ChatAccessStatusResponse.builder()
                .roomId(roomId)
                .roomMember(members)
                .build();
    }
}
