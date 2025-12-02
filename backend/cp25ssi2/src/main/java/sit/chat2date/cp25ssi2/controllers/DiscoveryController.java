package sit.chat2date.cp25ssi2.controllers;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.*;
import sit.chat2date.cp25ssi2.services.DiscoveryService; // <<== ใช้ services

import java.util.List;
// (ไม่ต้อง import jakarta.Validation หรือ jakarta.validation แบบทั่วไป)

@RestController
@RequestMapping("/discovery")
@Validated
public class DiscoveryController {

    private final DiscoveryService discoveryService;
    public DiscoveryController(DiscoveryService discoveryService) { this.discoveryService = discoveryService; }

    @GetMapping("")
    public ResponseEntity<List<DiscoveryResponse>> getDiscovery(
            @RequestParam(required = false, defaultValue = "0") @Min(0) int minDistance,
            @RequestParam(required = false, defaultValue = "1800") @Min(0) int maxDistance,
            @RequestParam @NotBlank String userId
    ) {
        List<DiscoveryResponse> responses = discoveryService.getCandidates(userId, minDistance, maxDistance);
        return ResponseEntity.ok(responses);
    }

    @PostMapping("/feedback")
    public ResponseEntity<FeedbackResponse> feedback(
            @RequestParam @NotBlank String userId,
            @RequestBody FeedbackRequest body
    ) {
        System.out.println("[Controller] /discovery/feedback userId=" + userId
                + " targetUserId=" + body.getTargetUserId()
                + " action=" + body.getAction());

        FeedbackResponse result = discoveryService.submitFeedback(
                userId,
                body.getTargetUserId(),
                body.getAction()
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }


}
