// src/main/java/sit/chat2date/cp25ssi2/dto/notification/MatchNotificationPayload.java
package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class MatchNotificationPayload {
    private String title;
    private String body;
    private String chatRoomId; // เผื่อใช้เปิดหน้าห้องแชท
}
