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
// (ไม่ต้อง import jakarta.Validation หรือ jakarta.validation แบบทั่วไป)

@RestController
@RequestMapping("/discovery")
@Validated
public class DiscoveryController {

    private final DiscoveryService discoveryService;
    public DiscoveryController(DiscoveryService discoveryService) { this.discoveryService = discoveryService; }

    @GetMapping("/")
    public ResponseEntity<DiscoveryGetResponse> getDiscovery(
            @RequestParam @Min(0) int minDistance,
            @RequestParam @Min(0) int maxDistance,
            @RequestParam @NotBlank String userId
    ) {
        var user = discoveryService.getCandidate(userId, minDistance, maxDistance);
        return ResponseEntity.ok(new DiscoveryGetResponse(user));
    }

    @PostMapping("/feedback")
    public ResponseEntity<FeedbackResponse> feedback(
            @RequestHeader("Authorization") String accessToken,
            @RequestBody FeedbackRequest body
    ) {
        String result = discoveryService.submitFeedback(body.getTargetUserId(), body.getAction(), accessToken);
        return ResponseEntity.status(HttpStatus.CREATED).body(new FeedbackResponse(result));
    }
}
