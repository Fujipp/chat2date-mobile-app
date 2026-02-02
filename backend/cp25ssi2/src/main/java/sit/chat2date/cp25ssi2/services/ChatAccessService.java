package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sit.chat2date.cp25ssi2.dto.ChatAccessRequest;
import sit.chat2date.cp25ssi2.dto.ChatAccessStatusResponse;
import sit.chat2date.cp25ssi2.dto.MessagesReadPayload;
import sit.chat2date.cp25ssi2.entities.ChatAccessLog;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.enums.ChatAccessActionType;
import sit.chat2date.cp25ssi2.exceptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.ChatAccessLogRepository;
import sit.chat2date.cp25ssi2.repositories.MatchRepository;
import sit.chat2date.cp25ssi2.repositories.MessageRepository;

import java.time.LocalDateTime;
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
     * Uses update if record exists, otherwise creates new
     */
    @Transactional
    public void enterRoom(String userId, ChatAccessRequest request) {
        System.out
                .println("[ChatAccessService] enterRoom called - userId=" + userId + ", roomId=" + request.getRoomId());

        if (request.getType() != ChatAccessActionType.ENTER) {
            throw new BadRequestException("Invalid action type for enter");
        }

        Integer roomId = Integer.parseInt(request.getRoomId());
        System.out.println("[ChatAccessService] Looking for match with roomId=" + roomId);

        Match match = matchRepository.findByIdAndUserId(roomId, userId)
                .orElseThrow(() -> new NotFoundException("Room not found"));
        System.out.println("[ChatAccessService] Found match: " + match.getId());

        if (!match.getUserId1().getUserId().equals(userId) && !match.getUserId2().getUserId().equals(userId)) {
            throw new ForbiddenAccessException("Access denied to this room");
        }

        // Find existing record or create new one
        System.out.println("[ChatAccessService] Looking for existing access log");
        Optional<ChatAccessLog> existingLog = chatAccessLogRepository
                .findFirstByRoomIdAndUserIdOrderByCreatedAtDesc(roomId, userId);

        if (existingLog.isPresent()) {
            // Update existing record
            System.out.println("[ChatAccessService] Updating existing access log");
            ChatAccessLog accessLog = existingLog.get();
            accessLog.setActionType(ChatAccessActionType.ENTER);
            chatAccessLogRepository.save(accessLog);
        } else {
            // Create new record
            System.out.println("[ChatAccessService] Creating new access log");
            ChatAccessLog accessLog = ChatAccessLog.builder()
                    .userId(userId)
                    .roomId(roomId)
                    .actionType(ChatAccessActionType.ENTER)
                    .build();
            chatAccessLogRepository.save(accessLog);
        }

        // Mark messages as read for this user
        System.out.println("[ChatAccessService] Marking messages as read");
        messageRepository.markMessagesAsRead(roomId, userId);
        System.out.println("[ChatAccessService] Messages marked as read successfully");

        // Broadcast to SENDER that their messages have been read
        // Partner = the person who SENT the messages (they should know their messages
        // are now read)
        String partnerId = match.getUserId1().getUserId().equals(userId)
                ? match.getUserId2().getUserId()
                : match.getUserId1().getUserId();

        // Broadcast events (wrapped in try-catch to prevent failures from breaking the
        // method)
        try {
            // Broadcast "messages read" event for real-time "เห็นแล้ว" status
            MessagesReadPayload readPayload = MessagesReadPayload.builder()
                    .roomId(request.getRoomId())
                    .readByUserId(userId)
                    .senderId(partnerId)
                    .readAt(LocalDateTime.now())
                    .build();
            chatSocketService.broadcastMessagesRead(request.getRoomId(), readPayload);

            // Partner's unread count for this room = 0 because we just read all their
            // messages
            chatSocketService.broadcastChatListUpdate(partnerId, request.getRoomId(), 0, null);

            // Also broadcast to SELF that their unread count is now 0
            chatSocketService.broadcastChatListUpdate(userId, request.getRoomId(), 0, null);

            // Broadcast status change
            ChatAccessStatusResponse status = getRoomAccessStatus(request.getRoomId());
            chatSocketService.broadcastAccessStatus(request.getRoomId(), status);
        } catch (Exception e) {
            // Log but don't fail - the messages are already marked as read
            System.err.println("[ChatAccessService] Failed to broadcast events: " + e.getMessage());
        }
    }

    /**
     * Exit a chat room
     * Uses update if record exists, otherwise creates new
     */
    @Transactional
    public void exitRoom(String userId, ChatAccessRequest request) {
        if (request.getType() != ChatAccessActionType.EXIT) {
            throw new BadRequestException("Invalid action type for exit");
        }

        Integer roomId = Integer.parseInt(request.getRoomId());
        Match match = matchRepository.findByIdAndUserId(roomId, userId)
                .orElseThrow(() -> new NotFoundException("Room not found"));

        if (!match.getUserId1().getUserId().equals(userId) && !match.getUserId2().getUserId().equals(userId)) {
            throw new ForbiddenAccessException("Access denied to this room");
        }

        // Find existing record or create new one
        Optional<ChatAccessLog> existingLog = chatAccessLogRepository
                .findFirstByRoomIdAndUserIdOrderByCreatedAtDesc(roomId, userId);

        if (existingLog.isPresent()) {
            // Update existing record
            ChatAccessLog accessLog = existingLog.get();
            accessLog.setActionType(ChatAccessActionType.EXIT);
            chatAccessLogRepository.save(accessLog);
        } else {
            // Create new record
            ChatAccessLog accessLog = ChatAccessLog.builder()
                    .userId(userId)
                    .roomId(roomId)
                    .actionType(ChatAccessActionType.EXIT)
                    .build();
            chatAccessLogRepository.save(accessLog);
        }

        // Broadcast status change
        ChatAccessStatusResponse status = getRoomAccessStatus(request.getRoomId());
        chatSocketService.broadcastAccessStatus(request.getRoomId(), status);
    }

    /**
     * Get room access status for all members
     */
    public ChatAccessStatusResponse getRoomAccessStatus(String roomIdStr) {
        Integer roomId = Integer.parseInt(roomIdStr);
        Match match = matchRepository.findById(roomId)
                .orElseThrow(() -> new NotFoundException("Room not found"));

        // Get all access logs for this room (now each user has only 1 record)
        List<ChatAccessLog> accessLogs = chatAccessLogRepository.findAllByRoomId(roomId);

        List<ChatAccessStatusResponse.RoomMember> members = List.of(
                match.getUserId1().getUserId(),
                match.getUserId2().getUserId()).stream().map(userId -> {
                    ChatAccessActionType status = accessLogs.stream()
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
                .roomId(roomIdStr)
                .roomMember(members)
                .build();
    }
}
