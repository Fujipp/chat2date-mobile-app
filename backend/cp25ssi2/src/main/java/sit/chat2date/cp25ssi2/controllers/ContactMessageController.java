package sit.chat2date.cp25ssi2.controllers;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.ContactMessageRequest;
import sit.chat2date.cp25ssi2.dto.ContactMessageResponse;
import sit.chat2date.cp25ssi2.dto.ContactReplyRequest;
import sit.chat2date.cp25ssi2.entities.ContactMessage;
import sit.chat2date.cp25ssi2.services.ContactMessageService;

import java.util.List;
import java.util.Map;

/**
 * REST controller for contact messages.
 * Users can send contact messages; admins can list and reply.
 */
@RestController
@RequiredArgsConstructor
public class ContactMessageController {

    private final ContactMessageService contactMessageService;

    // ────────────────────────────────────────────────────────────────────────
    // User
    // ────────────────────────────────────────────────────────────────────────

    /** POST /contact — Send a contact message to the support team. Returns 201 Created. */
    @PostMapping("/contact")
    public ResponseEntity<?> sendContactMessage(
            @RequestAttribute("userId") String userId,
            @Valid @RequestBody ContactMessageRequest req) {

        Integer contactId = contactMessageService.createContactMessage(userId, req);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "contactId", contactId,
                "message", "ส่งข้อความติดต่อเรียบร้อยแล้ว ทีมงานจะติดต่อกลับทางอีเมล"
        ));
    }

    // ────────────────────────────────────────────────────────────────────────
    // Admin
    // ────────────────────────────────────────────────────────────────────────

    /** GET /admin/contact — List all contact messages (admin-only). */
    @GetMapping("/admin/contact")
    public ResponseEntity<List<ContactMessageResponse>> getAllContactMessages() {
        return ResponseEntity.ok(contactMessageService.getAllContactMessages());
    }

    /** POST /admin/contact/{contactId}/reply — Reply to a contact message (admin-only). */
    @PostMapping("/admin/contact/{contactId}/reply")
    public ResponseEntity<?> replyToContactMessage(
            @PathVariable Integer contactId,
            @Valid @RequestBody ContactReplyRequest req) {

        contactMessageService.replyContactMessage(contactId, req);
        return ResponseEntity.ok(Map.of("message", "ตอบกลับเรียบร้อยแล้ว"));
    }
}