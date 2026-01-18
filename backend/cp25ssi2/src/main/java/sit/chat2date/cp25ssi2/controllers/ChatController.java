package sit.chat2date.cp25ssi2.controllers;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.*;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.services.ChatAccessService;
import sit.chat2date.cp25ssi2.services.ChatService;

import java.util.Optional;

@RestController
@RequestMapping("/api/v1/chats")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;
    private final ChatAccessService chatAccessService;

    /**
     * GET /api/v1/chats/rooms - Get all chat rooms for current user
     */
    @GetMapping("/rooms")
    public ResponseEntity<ChatRoomListResponse> getAllChatRooms(
            @AuthenticationPrincipal Optional<User> userOpt) {
        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        ChatRoomListResponse response = chatService.getAllChatRooms(user.getUserId());
        return ResponseEntity.ok(response);
    }

    /**
     * GET /api/v1/chats/{roomId} - Get chat messages for a room with pagination
     */
    @GetMapping("/{roomId}")
    public ResponseEntity<ChatRoomDetailResponse> getChatMessages(
            @AuthenticationPrincipal Optional<User> userOpt,
            @PathVariable String roomId,
            @RequestParam(defaultValue = "0") Integer paginate) {
        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        ChatRoomDetailResponse response = chatService.getChatMessages(user.getUserId(), roomId, paginate);
        return ResponseEntity.ok(response);
    }

    /**
     * POST /api/v1/chats/send - Send a message
     */
    @PostMapping("/send")
    public ResponseEntity<SendMessageResponse> sendMessage(
            @AuthenticationPrincipal Optional<User> userOpt,
            @Valid @RequestBody SendMessageRequest request) {
        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        SendMessageResponse response = chatService.sendMessage(user.getUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * POST /api/v1/chats/access - Enter a room (update read status)
     */
    @PostMapping("/access")
    public ResponseEntity<Void> enterRoom(
            @AuthenticationPrincipal Optional<User> userOpt,
            @Valid @RequestBody ChatAccessRequest request) {
        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        chatAccessService.enterRoom(user.getUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    /**
     * PUT /api/v1/chats/access - Exit a room
     */
    @PutMapping("/access")
    public ResponseEntity<Void> exitRoom(
            @AuthenticationPrincipal Optional<User> userOpt,
            @Valid @RequestBody ChatAccessRequest request) {
        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        chatAccessService.exitRoom(user.getUserId(), request);
        return ResponseEntity.ok().build();
    }

    /**
     * GET /api/v1/chats/access/{roomId} - Get room member access status
     */
    @GetMapping("/access/{roomId}")
    public ResponseEntity<ChatAccessStatusResponse> getRoomAccessStatus(
            @AuthenticationPrincipal Optional<User> userOpt,
            @PathVariable String roomId) {
        userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        ChatAccessStatusResponse response = chatAccessService.getRoomAccessStatus(roomId);
        return ResponseEntity.ok(response);
    }
}
