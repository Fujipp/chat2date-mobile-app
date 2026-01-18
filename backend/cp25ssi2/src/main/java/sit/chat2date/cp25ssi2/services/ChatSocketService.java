package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.dto.SendMessageResponse;

@Service
@RequiredArgsConstructor
public class ChatSocketService {

    private final SimpMessagingTemplate messagingTemplate;

    /**
     * Broadcast a message to room subscribers
     */
    public void broadcastMessage(String roomId, String userId1, String userId2, SendMessageResponse message) {
        // Send to room topic
        messagingTemplate.convertAndSend("/topic/chat/" + roomId, message);

        // Notify both users
        messagingTemplate.convertAndSend("/topic/chat/user/" + userId1, message);
        messagingTemplate.convertAndSend("/topic/chat/user/" + userId2, message);
    }

    /**
     * Notify a user about a chat event (e.g., new message notification)
     */
    public void notifyUser(String userId, Object payload) {
        messagingTemplate.convertAndSend("/topic/chat/user/" + userId, payload);
    }

    /**
     * Broadcast room access status change
     */
    public void broadcastAccessStatus(String roomId, Object status) {
        messagingTemplate.convertAndSend("/topic/chat/" + roomId + "/access", status);
    }
}
