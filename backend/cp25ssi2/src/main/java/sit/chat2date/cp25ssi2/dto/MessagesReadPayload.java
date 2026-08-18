package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Payload for WebSocket broadcast when messages are read
 * Sent to /topic/chat/{roomId}/read
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MessagesReadPayload {
    private String roomId;
    private String readByUserId; // Who read the messages (the receiver)
    private String senderId; // Whose messages were read (the sender who should see "เห็นแล้ว")
    private LocalDateTime readAt;
}
