package sit.chat2date.cp25ssi2.controllers;

import com.google.firebase.messaging.FirebaseMessagingException;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.services.NotificationService;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping("/test-token")
    public ResponseEntity<?> sendTest(@RequestBody TestNotificationRequest req)
            throws FirebaseMessagingException {

        String messageId = notificationService.sendTestToToken(req.getFcmToken());
        return ResponseEntity.ok().body(
                new SimpleResponse("OK", "Sent FCM message id: " + messageId)
        );
    }

    @Data
    public static class TestNotificationRequest {
        private String fcmToken;
    }

    @Data
    public static class SimpleResponse {
        private final String status;
        private final String message;
    }
}
