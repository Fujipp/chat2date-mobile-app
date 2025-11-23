package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final DeviceTokenService deviceTokenService;

    // TODO: ไว้ต่อกับ Firebase Admin SDK ภายหลัง
    public void sendNewMatchNotification(String userId, String matchedUserName) {
        List<String> tokens = deviceTokenService.getTokensForUser(userId);

        // ตรงนี้ตอนนี้แค่ log ไว้ก่อน
        System.out.println("[NOTIFY] send match notification to " + userId);
        System.out.println("Tokens: " + tokens);
        System.out.println("Matched with: " + matchedUserName);

        // ภายหลังจะเปลี่ยนเป็น:
        // for (String token : tokens) { firebaseMessaging.send(...); }
    }
}
    