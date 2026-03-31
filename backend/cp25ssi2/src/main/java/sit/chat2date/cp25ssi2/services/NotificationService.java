package sit.chat2date.cp25ssi2.services;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final FirebaseApp firebaseApp; // แค่ inject ไว้ให้แน่ใจว่า init แล้ว
    private final DeviceTokenService deviceTokenService;

    public String sendTestToToken(String fcmToken) throws FirebaseMessagingException {
        // สร้าง message แบบง่าย ๆ
        Message message = Message.builder()
                .setToken(fcmToken)
                .setNotification(Notification.builder()
                        .setTitle("Chat2Date Test")
                        .setBody("This is a test notification from backend.")
                        .build())
                .putData("type", "TEST") // data เผื่อใช้ในอนาคต
                .build();

        // ส่งข้อความ
        return FirebaseMessaging.getInstance().send(message);
    }

    // ★ ใหม่: ส่งแจ้งเตือนเมื่อ match (รองรับ deep link ไป chat)
    public void sendMatchNotification(String receiverUserId, String partnerNickname,
            Integer roomId, String partnerUserId, String partnerAvatarUrl) {
        // ดึง FCM token ของ user คนที่จะได้รับแจ้งเตือน
        List<String> tokens = deviceTokenService.getTokensForUser(receiverUserId);
        if (tokens == null || tokens.isEmpty()) {
            return;
        }

        for (String token : tokens) {
            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(
                            Notification.builder()
                                    .setTitle("It's a match! 🎉")
                                    .setBody("คุณกับ " + partnerNickname + " match กันแล้ว ลองเริ่มคุยกันดูสิ")
                                    .build())
                    .putData("type", "MATCH")
                    .putData("roomId", roomId != null ? roomId.toString() : "")
                    .putData("targetUserId", partnerUserId != null ? partnerUserId : "")
                    .putData("userName", partnerNickname != null ? partnerNickname : "")
                    .putData("avatarUrl", partnerAvatarUrl != null ? partnerAvatarUrl : "")
                    .build();

            try {
                FirebaseMessaging.getInstance().send(message);
            } catch (FirebaseMessagingException e) {
                // Failed to send MATCH notification
            }
        }
    }

    // ★ ใหม่: ส่งแจ้งเตือนเมื่อมีข้อความใหม่
    public void sendChatMessageNotification(String receiverUserId, String senderNickname,
            String messagePreview, Integer roomId, String senderUserId, String senderAvatarUrl) {
        List<String> tokens = deviceTokenService.getTokensForUser(receiverUserId);
        if (tokens == null || tokens.isEmpty()) {
            return;
        }

        // ตัดข้อความให้สั้นลงถ้ายาวเกินไป
        String preview = messagePreview != null && messagePreview.length() > 50
                ? messagePreview.substring(0, 47) + "..."
                : messagePreview;

        for (String token : tokens) {
            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(
                            Notification.builder()
                                    .setTitle("ข้อความใหม่จาก " + senderNickname + " 💬")
                                    .setBody(preview)
                                    .build())
                    .putData("type", "CHAT_MESSAGE")
                    .putData("roomId", roomId != null ? roomId.toString() : "")
                    .putData("targetUserId", senderUserId != null ? senderUserId : "")
                    .putData("userName", senderNickname != null ? senderNickname : "")
                    .putData("avatarUrl", senderAvatarUrl != null ? senderAvatarUrl : "")
                    .build();

            try {
                FirebaseMessaging.getInstance().send(message);
            } catch (FirebaseMessagingException e) {
                // Failed to send CHAT_MESSAGE notification
            }
        }
    }

    // ★ ใหม่: ส่งแจ้งเตือนล่วงหน้าก่อนวันนัด 1 วัน
    public void sendAppointmentReminderNotification(String receiverUserId, String partnerNickname,
            Integer roomId, String placeName, LocalDateTime appointmentDateTimeUtc) {
        List<String> tokens = deviceTokenService.getTokensForUser(receiverUserId);
        if (tokens == null || tokens.isEmpty()) {
            return;
        }

        // แปลงเวลาจาก UTC ใน DB เป็นเวลาไทย (+7)
        LocalDateTime bangkokTime = appointmentDateTimeUtc.plusHours(7);
        String formattedDateTime = bangkokTime.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

        for (String token : tokens) {
            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(
                            Notification.builder()
                                    .setTitle("พรุ่งนี้มีนัดเดตนะ! 📅")
                                    .setBody("คุณมีนัดที่ " + placeName + " กับ " + partnerNickname + " วันที่ " + formattedDateTime + " น.")
                                    .build())
                    .putData("type", "APPOINTMENT_REMINDER")
                    .putData("roomId", roomId != null ? roomId.toString() : "")
                    .build();

            try {
                FirebaseMessaging.getInstance().send(message);
            } catch (FirebaseMessagingException e) {
                // Failed to send APPOINTMENT_REMINDER notification
            }
        }
    }
}
