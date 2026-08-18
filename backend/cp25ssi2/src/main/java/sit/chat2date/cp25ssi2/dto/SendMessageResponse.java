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
public class SendMessageResponse {
    private String roomId;
    private Long messageId;
    private String message;
    private String senderId;
    private LocalDateTime created;
    private MessageType type;
    private Boolean isRead;
    private String gameStatus;
}
