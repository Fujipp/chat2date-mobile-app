package sit.chat2date.cp25ssi2.services;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

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
                .putData("type", "TEST")  // data เผื่อใช้ในอนาคต
                .build();

        // ส่งข้อความ
        return FirebaseMessaging.getInstance().send(message);
    }
    // ★ ใหม่: ส่งแจ้งเตือนเมื่อ match
    public void sendMatchNotification(String receiverUserId, String partnerNickname) {
        // ดึง FCM token ของ user คนที่จะได้รับแจ้งเตือน
        List<String> tokens = deviceTokenService.getTokensForUser(receiverUserId);
        if (tokens == null || tokens.isEmpty()) {
            System.out.println("[FCM] No device token for user " + receiverUserId);
            return;
        }

        for (String token : tokens) {
            Message message = Message.builder()
                    .setToken(token)
                    .setNotification(
                            Notification.builder()
                                    .setTitle("It's a match! 🎉")
                                    .setBody("คุณกับ " + partnerNickname + " match กันแล้ว ลองเริ่มคุยกันดูสิ")
                                    .build()
                    )
                    .putData("type", "MATCH")
                    .putData("partnerNickname", partnerNickname)
                    // ถ้าอนาคตมี chatRoomId ก็ putData เพิ่มได้
                    .build();

            // จะใช้ sendAsync ก็ได้ แต่ระหว่าง dev ใช้ send ธรรมดาก่อน
            try {
                String msgId = FirebaseMessaging.getInstance().send(message);
                System.out.println("[FCM] Sent MATCH to " + receiverUserId + " msgId=" + msgId);
            } catch (FirebaseMessagingException e) {
                System.out.println("[FCM] Failed to send MATCH to " + receiverUserId + " : " + e.getMessage());
            }
        }
    }
}
