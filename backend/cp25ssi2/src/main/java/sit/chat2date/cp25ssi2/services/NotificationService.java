package sit.chat2date.cp25ssi2.services;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final FirebaseApp firebaseApp; // แค่ inject ไว้ให้แน่ใจว่า init แล้ว

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
}
