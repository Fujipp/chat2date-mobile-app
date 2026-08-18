package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomDTO {
    private String roomId; // matchId as string
    private String partnerId;
    private String partnerName;
    private String partnerImage;
    private String lastMessage;
    private LocalDateTime lastMessageTime; // for sorting by latest message
    private Integer unreadCount;
    private String type; // "new" or "old"
}
