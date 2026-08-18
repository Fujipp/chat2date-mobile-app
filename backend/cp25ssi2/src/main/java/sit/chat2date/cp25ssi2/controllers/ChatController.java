package sit.chat2date.cp25ssi2.controllers;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.ChatAccessRequest;
import sit.chat2date.cp25ssi2.dto.ChatAccessStatusResponse;
import sit.chat2date.cp25ssi2.dto.ChatRoomDetailResponse;
import sit.chat2date.cp25ssi2.dto.ChatRoomListResponse;
import sit.chat2date.cp25ssi2.dto.SendMessageRequest;
import sit.chat2date.cp25ssi2.dto.SendMessageResponse;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.UnauthorizedAccessException;
import sit.chat2date.cp25ssi2.services.ChatAccessService;
import sit.chat2date.cp25ssi2.services.ChatService;

import java.util.Optional;

/**
 * REST controller for chat functionality.
 * Handles chat rooms, messages, and room access (enter/exit) tracking.
 */
@RestController
@RequestMapping("/chats")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;
    private final ChatAccessService chatAccessService;

    // ────────────────────────────────────────────────────────────────────────
    // Chat Rooms & Messages
    // ────────────────────────────────────────────────────────────────────────

    /** GET /chats/rooms — List all chat rooms for the authenticated user. */
    @GetMapping("/rooms")
    public ResponseEntity<ChatRoomListResponse> getChatRooms(
            @AuthenticationPrincipal Optional<User> userOpt) {
        User user = getAuthenticatedUser(userOpt);
        return ResponseEntity.ok(chatService.getAllChatRooms(user.getUserId()));
    }

    /** GET /chats/{roomId} — Get paginated messages for a specific room. */
    @GetMapping("/{roomId}")
    public ResponseEntity<ChatRoomDetailResponse> getMessages(
            @AuthenticationPrincipal Optional<User> userOpt,
            @PathVariable String roomId,
            @RequestParam(defaultValue = "0") Integer paginate) {
        User user = getAuthenticatedUser(userOpt);
        return ResponseEntity.ok(chatService.getChatMessages(user.getUserId(), roomId, paginate));
    }

    /** POST /chats/send — Send a new message. Returns 201 Created. */
    @PostMapping("/send")
    public ResponseEntity<SendMessageResponse> sendMessage(
            @AuthenticationPrincipal Optional<User> userOpt,
            @Valid @RequestBody SendMessageRequest request) {
        User user = getAuthenticatedUser(userOpt);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(chatService.sendMessage(user.getUserId(), request));
    }

    // ────────────────────────────────────────────────────────────────────────
    // Room Access (Enter / Exit)
    // ────────────────────────────────────────────────────────────────────────

    /** POST /chats/access — Enter a room (marks messages as read). */
    @PostMapping("/access")
    public ResponseEntity<Void> enterRoom(
            @AuthenticationPrincipal Optional<User> userOpt,
            @Valid @RequestBody ChatAccessRequest request) {
        User user = getAuthenticatedUser(userOpt);
        chatAccessService.enterRoom(user.getUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    /** PUT /chats/access — Exit a room. */
    @PutMapping("/access")
    public ResponseEntity<Void> exitRoom(
            @AuthenticationPrincipal Optional<User> userOpt,
            @Valid @RequestBody ChatAccessRequest request) {
        User user = getAuthenticatedUser(userOpt);
        chatAccessService.exitRoom(user.getUserId(), request);
        return ResponseEntity.ok().build();
    }

    /** GET /chats/access/{roomId} — Get online/offline status of room members. */
    @GetMapping("/access/{roomId}")
    public ResponseEntity<ChatAccessStatusResponse> getRoomAccessStatus(
            @AuthenticationPrincipal Optional<User> userOpt,
            @PathVariable String roomId) {
        getAuthenticatedUser(userOpt);
        return ResponseEntity.ok(chatAccessService.getRoomAccessStatus(roomId));
    }

    // ────────────────────────────────────────────────────────────────────────
    // Helpers
    // ────────────────────────────────────────────────────────────────────────

    private User getAuthenticatedUser(Optional<User> userOpt) {
        return userOpt.orElseThrow(() -> new UnauthorizedAccessException("User not found"));
    }
}
