package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import sit.chat2date.cp25ssi2.enums.MessageType;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDTO {
    private String senderId;
    private String messageId;
    private String message;
    private LocalDateTime created;
    private MessageType type;
}
