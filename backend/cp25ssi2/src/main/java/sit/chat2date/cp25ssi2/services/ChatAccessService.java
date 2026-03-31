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
        if (request.getType() != ChatAccessActionType.ENTER) {
            throw new BadRequestException("Invalid action type for enter");
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
            accessLog.setActionType(ChatAccessActionType.ENTER);
            chatAccessLogRepository.save(accessLog);
        } else {
            // Create new record
            ChatAccessLog accessLog = ChatAccessLog.builder()
                    .userId(userId)
                    .roomId(roomId)
                    .actionType(ChatAccessActionType.ENTER)
                    .build();
            chatAccessLogRepository.save(accessLog);
        }

        // Mark messages as read for this user
        messageRepository.markMessagesAsRead(roomId, userId);

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

            // Calculate partner's ACTUAL unread count (messages sent by current user that partner hasn't read yet)
            // Do NOT hardcode 0 — partner may still have unread messages from us
            Integer partnerUnreadCount = messageRepository.countUnreadMessages(roomId, partnerId);
            chatSocketService.broadcastChatListUpdate(partnerId, request.getRoomId(), partnerUnreadCount, null);

            // Broadcast to SELF that their unread count is now 0 (we just read everything)
            chatSocketService.broadcastChatListUpdate(userId, request.getRoomId(), 0, null);

            // Broadcast status change
            ChatAccessStatusResponse status = getRoomAccessStatus(request.getRoomId());
            chatSocketService.broadcastAccessStatus(request.getRoomId(), status);
        } catch (Exception e) {
            // Log but don't fail - the messages are already marked as read
            // Failed to broadcast events
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
