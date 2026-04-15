package sit.chat2date.cp25ssi2.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sit.chat2date.cp25ssi2.dto.*;
import sit.chat2date.cp25ssi2.entities.*;
import sit.chat2date.cp25ssi2.enums.MessageType;
import sit.chat2date.cp25ssi2.enums.NotifyStatus;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceptions.TooManyRequestException;
import sit.chat2date.cp25ssi2.repositories.*;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final MatchRepository matchRepository;
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final UserPhotoRepository userPhotoRepository;
    private final RelationshipStatsRepository relationshipStatsRepository;
    private final ReportRepository reportRepository;
    private final UserHasInterestRepository userHasInterestRepository;
    private final UserHasLifestyleRepository userHasLifestyleRepository;
    private final UserHasTravelstyleRepository userHasTravelstyleRepository;
    private final UserLocationRepository userLocationRepository;
    private final ChatSocketService chatSocketService;
    private final NotificationService notificationService;
    private final ObjectMapper objectMapper;
    private final RedisTemplate<String, Object> redisTemplate;

    @Lazy
    @Autowired
    private GameService gameService;

    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final int RATE_LIMIT_MAX_MESSAGES = 30; // Max messages per window
    private static final int RATE_LIMIT_WINDOW_SECONDS = 60; // 1 minute window

    /**
     * Get all chat rooms for a user (using Match as Room)
     */
    public ChatRoomListResponse getAllChatRooms(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));

        List<Match> matches = matchRepository.findAllByUser(user);

        List<ChatRoomDTO> roomDTOs = matches.stream().map(match -> {
                    Integer roomId = match.getId();

                    // ดึง stats มาเช็ค
                    RelationshipStats stats = relationshipStatsRepository.findByRoomId(roomId).orElse(null);
                    if (stats != null) {
                        boolean isUser1 = match.getUserId1().getUserId().equals(userId);
                        NotifyStatus unmatchStatus = stats.getNotiUnmatch();
                        NotifyStatus mySide = isUser1 ? NotifyStatus.LEFT : NotifyStatus.RIGHT;

                        // ถ้าสถานะเป็น BOTH หรือเป็นฝั่งเราเอง แปลว่าแจ้งเตือน "จบความสัมพันธ์" ไปแล้ว
                        // ให้คืนค่า null เพื่อ filter ออกจาก List (ทำให้ห้องหายไป)
                        if (unmatchStatus == NotifyStatus.BOTH || unmatchStatus == mySide) {
                            return null;
                        }
                    }
                    User partner = match.getUserId1().getUserId().equals(userId)
                            ? match.getUserId2() : match.getUserId1();

                    if (match.getDeleteFlag()) {
                        return null;
                    }

                    // Get latest message for this room
                    var latestMessage = messageRepository.findFirstByRoomIdOrderByCreatedAtDesc(roomId);
                    String lastMessage = latestMessage.map(Message::getMessage).orElse("");
                    var lastMessageTime = latestMessage.map(Message::getCreatedAt).orElse(match.getCreatedAt());

                    Integer unreadCount = messageRepository.countUnreadMessages(roomId, userId);

                    // Determine if new (no messages yet) or old
                    boolean hasMessages = latestMessage.isPresent();
                    String type = hasMessages ? "old" : "new";

                    return ChatRoomDTO.builder()
                            .roomId(String.valueOf(roomId))
                            .partnerId(partner.getUserId())
                            .partnerName(partner.getNickname())
                            .partnerImage(getFirstPhoto(partner.getUserId()))
                            .lastMessage(lastMessage)
                            .lastMessageTime(lastMessageTime)
                            .unreadCount(unreadCount)
                            .type(type)
                            .build();
                })
                .filter(Objects::nonNull)
                // Sort by lastMessageTime descending (latest first)
                .sorted((a, b) -> b.getLastMessageTime().compareTo(a.getLastMessageTime()))
                .collect(Collectors.toList());

        return ChatRoomListResponse.builder().rooms(roomDTOs).build();
    }

    /**
     * Get chat messages for a room with pagination
     */
    public ChatRoomDetailResponse getChatMessages(String userId, String roomIdStr, int page) {
        Integer roomId = Integer.parseInt(roomIdStr);
        Match match = matchRepository.findByIdAndUserId(roomId, userId)
                .orElseThrow(() -> new NotFoundException("Room not found"));

        // Check if user is member of match
        if (!match.getUserId1().getUserId().equals(userId) && !match.getUserId2().getUserId().equals(userId)) {
            throw new ForbiddenAccessException("Access denied to this room");
        }

        User partner = match.getUserId1().getUserId().equals(userId)
                ? match.getUserId2()
                : match.getUserId1();

        Pageable pageable = PageRequest.of(page, DEFAULT_PAGE_SIZE);
        Page<Message> messages = messageRepository.findByRoomIdOrderByCreatedAtDesc(roomId, pageable);

        List<ChatMessageDTO> chatMessages = messages.getContent().stream()
                .map(msg -> ChatMessageDTO.builder()
                        .senderId(msg.getSenderId())
                        .messageId(msg.getMessageId())
                        .message(msg.getMessage())
                        .created(msg.getCreatedAt())
                        .type(msg.getMessageType())
                        .isRead(msg.getIsRead())
                        .build())
                .collect(Collectors.toList());

        // Reverse to show oldest first
        Collections.reverse(chatMessages);

        // Check if user has read all messages
        Integer unreadCount = messageRepository.countUnreadMessages(roomId, userId);
        Boolean isRead = unreadCount == 0;

        Integer relationshipScore = relationshipStatsRepository.findByRoomId(roomId)
                .map(RelationshipStats::getScore)
                .orElse(0);

        // Check if chat is disabled due to report between users
        boolean isChatDisabled = reportRepository.existsByReporterIdAndTargetUserIdOrReporterIdAndTargetUserId(
                userId, partner.getUserId(),
                partner.getUserId(), userId);

        return ChatRoomDetailResponse.builder()
                .room(ChatRoomDetailResponse.RoomInfo.builder()
                        .roomId(roomIdStr)
                        .isRead(isRead)
                        .isChatDisabled(isChatDisabled)
                        .build())
                .chat(chatMessages)
                .partner(ChatRoomDetailResponse.PartnerInfo.builder()
                        .senderName(partner.getNickname())
                        .senderImage(getPhotos(partner.getUserId()))
                        .interests(getInterestIds(partner.getUserId()))
                        .lifeStyles(getLifeStyleIds(partner.getUserId()))
                        .travelStyles(getTravelStyleIds(partner.getUserId()))
                        .distance(calculateDistanceKm(userId, partner.getUserId()))
                        .build())
                .relationshipScore(relationshipScore)
                .build();
    }

    /**
     * Send a message with rate limiting (429 TOO MANY REQUESTS)
     */
    @Transactional
    public SendMessageResponse sendMessage(String userId, SendMessageRequest request) {
        // Rate limiting check
        checkRateLimit(userId);

        Integer roomId = Integer.parseInt(request.getRoomId());
        Match match = matchRepository.findByIdAndUserId(roomId, userId)
                .orElseThrow(() -> new NotFoundException("Room not found"));

        if (!match.getUserId1().getUserId().equals(userId) && !match.getUserId2().getUserId().equals(userId)) {
            throw new ForbiddenAccessException("Access denied to this room");
        }

        // Check if chat is disabled due to report
        String partnerId = match.getUserId1().getUserId().equals(userId)
                ? match.getUserId2().getUserId()
                : match.getUserId1().getUserId();
        if (reportRepository.existsByReporterIdAndTargetUserIdOrReporterIdAndTargetUserId(
                userId, partnerId, partnerId, userId)) {
            throw new ForbiddenAccessException("ไม่สามารถส่งข้อความได้เนื่องจากมีการรายงานผู้ใช้");
        }

        Message message = Message.builder()
                .roomId(roomId)
                .senderId(userId)
                .message(request.getMessage())
                .messageType(MessageType.TEXT)
                .isRead(false)
                .build();

        message = messageRepository.save(message);

        SendMessageResponse response = SendMessageResponse.builder()
                .roomId(String.valueOf(message.getRoomId()))
                .messageId(message.getMessageId())
                .message(message.getMessage())
                .senderId(message.getSenderId())
                .created(message.getCreatedAt())
                .type(message.getMessageType())
                .build();

        // Broadcast via WebSocket to room
        chatSocketService.broadcastMessage(request.getRoomId(), match.getUserId1().getUserId(),
                match.getUserId2().getUserId(), response);

        // Broadcast chat list update to EACH user with THEIR unread count
        // partnerId already defined above for report check

        // For sender: unread count = 0 (they sent it, so no unread for them)
        chatSocketService.broadcastChatListUpdate(userId, request.getRoomId(), 0, request.getMessage());

        // For receiver: calculate their actual unread count
        Integer receiverUnreadCount = messageRepository.countUnreadMessages(roomId, partnerId);
        chatSocketService.broadcastChatListUpdate(partnerId, request.getRoomId(), receiverUnreadCount,
                request.getMessage());

        // ★ ส่ง push notification แจ้งเตือนข้อความใหม่ให้ receiver
        try {
            User sender = userRepository.findByUserId(userId).orElse(null);
            String senderNickname = sender != null ? sender.getNickname() : "Someone";
            String senderAvatarUrl = getFirstPhoto(userId);
            notificationService.sendChatMessageNotification(
                    partnerId, senderNickname, request.getMessage(), roomId, userId,
                    senderAvatarUrl);
        } catch (Exception e) {
            // Failed to send notification
        }

        return response;
    }

    /**
     * Check rate limit for user - throws 429 if exceeded
     */
    private void checkRateLimit(String userId) {
        String key = "chat:ratelimit:" + userId;

        try {
            Long currentCount = redisTemplate.opsForValue().increment(key);

            if (currentCount != null && currentCount == 1) {
                // First message in window, set expiry
                redisTemplate.expire(key, RATE_LIMIT_WINDOW_SECONDS, TimeUnit.SECONDS);
            }

            if (currentCount != null && currentCount > RATE_LIMIT_MAX_MESSAGES) {
                throw new TooManyRequestException("Rate limit exceeded. Maximum "
                        + RATE_LIMIT_MAX_MESSAGES + " messages per minute.");
            }
        } catch (TooManyRequestException e) {
            throw e;
        } catch (Exception e) {
            // Redis error - allow request to proceed (fail open)
            // Rate limit check failed - allow request to proceed
        }
    }

    private String getFirstPhoto(String userId) {
        try {
            String jsonString = userPhotoRepository.findAttributesJsonByUser_UserId(userId);
            if (jsonString == null || jsonString.isEmpty()) {
                return null;
            }
            PhotoDTO photoDTO = objectMapper.readValue(jsonString, PhotoDTO.class);
            List<String> urls = photoDTO.getUrls() == null ? Collections.emptyList() : photoDTO.getUrls();
            return urls.isEmpty() ? null : urls.get(0);
        } catch (Exception e) {
            return null;
        }
    }

    private List<String> getPhotos(String userId) {
        try {
            String jsonString = userPhotoRepository.findAttributesJsonByUser_UserId(userId);
            if (jsonString == null || jsonString.isEmpty()) {
                return new ArrayList<>();
            }
            PhotoDTO photoDTO = objectMapper.readValue(jsonString, PhotoDTO.class);
            return photoDTO.getUrls() == null ? new ArrayList<>() : photoDTO.getUrls();
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    private List<Integer> getInterestIds(String userId) {
        return userHasInterestRepository.findAllByUser_UserId(userId).stream()
                .map(userHasInterest -> userHasInterest.getInterestInterest().getId())
                .collect(Collectors.toList());
    }

    private List<Integer> getLifeStyleIds(String userId) {
        return userHasLifestyleRepository.findAllByUser_UserId(userId).stream()
                .map(userHasLifestyle -> userHasLifestyle.getLifestyleLifestyle().getId())
                .collect(Collectors.toList());
    }

    private List<Integer> getTravelStyleIds(String userId) {
        return userHasTravelstyleRepository.findAllByUser_UserId(userId).stream()
                .map(userHasTravelstyle -> userHasTravelstyle.getTravelstyleTravel().getId())
                .collect(Collectors.toList());
    }

    private Double calculateDistanceKm(String userId, String partnerId) {
        UserLocation myLocation = userLocationRepository.findFirstByUser_UserId(userId);
        UserLocation partnerLocation = userLocationRepository.findFirstByUser_UserId(partnerId);
        if (myLocation == null || partnerLocation == null) {
            return null;
        }

        double lat1 = Math.toRadians(myLocation.getLatitude().doubleValue());
        double lon1 = Math.toRadians(myLocation.getLongitude().doubleValue());
        double lat2 = Math.toRadians(partnerLocation.getLatitude().doubleValue());
        double lon2 = Math.toRadians(partnerLocation.getLongitude().doubleValue());

        double deltaLat = lat2 - lat1;
        double deltaLon = lon2 - lon1;
        double a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2)
                + Math.cos(lat1) * Math.cos(lat2)
                * Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double earthRadiusKm = 6371.0;
        return earthRadiusKm * c;
    }

    public String getAnonymizedChatHistory(Integer roomId) {
        List<Message> messages = messageRepository.findLast50ByRoomIdOrderByCreatedAtDesc(roomId);

        Collections.reverse(messages);

        StringBuilder chatLog = new StringBuilder();
        for (Message msg : messages) {
            String senderName = msg.getSenderId().substring(0, 4); // ตัดมาแค่ 4 ตัวท้ายเพื่อปิดบัง

            chatLog.append(senderName).append(": ").append(msg.getMessage()).append("\n");
        }
        return chatLog.toString();
    }

    @Transactional
    public void sendSystemMessage(Integer roomId, String content, MessageType type) {
        Match match = matchRepository.findById(roomId)
                .orElseThrow(() -> new NotFoundException("Match not found"));

        Message message = Message.builder()
                .roomId(roomId)
                .senderId("SYSTEM")
                .message(content)
                .messageType(type)
                .isRead(false)
                .build();

        message = messageRepository.save(message);

        String userId1 = match.getUserId1().getUserId();
        GameCheckResponse gameStatus = gameService.checkGameStatus(roomId, userId1);

        SendMessageResponse response = SendMessageResponse.builder()
                .roomId(String.valueOf(message.getRoomId()))
                .messageId(message.getMessageId())
                .message(message.getMessage())
                .senderId("SYSTEM")
                .created(message.getCreatedAt())
                .type(message.getMessageType())
                .gameStatus(gameStatus.getGameStatus())
                .build();


        // REUSE: ใช้ chatSocketService ของเพื่อนเพื่อ Broadcast ไปหา User
        chatSocketService.broadcastMessage(
                String.valueOf(roomId),
                match.getUserId1().getUserId(),
                match.getUserId2().getUserId(),
                response
        );
    }
}
