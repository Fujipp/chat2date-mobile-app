package sit.chat2date.cp25ssi2.controllers;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.DiscoveryResponse;
import sit.chat2date.cp25ssi2.dto.FeedbackRequest;
import sit.chat2date.cp25ssi2.dto.FeedbackResponse;
import sit.chat2date.cp25ssi2.services.DiscoveryService;

import java.util.List;

/**
 * REST controller for user discovery (swiping).
 * Provides candidate profiles and handles like/dislike feedback.
 */
@RestController
@RequestMapping("/discovery")
@Validated
@RequiredArgsConstructor
public class DiscoveryController {

    private final DiscoveryService discoveryService;

    /** GET /discovery — Get candidate profiles within distance range for the given user. */
    @GetMapping("")
    public ResponseEntity<List<DiscoveryResponse>> getDiscovery(
            @RequestParam(required = false, defaultValue = "0") @Min(0) int minDistance,
            @RequestParam(required = false, defaultValue = "1800") @Min(0) int maxDistance,
            @RequestParam @NotBlank String userId
    ) {
        List<DiscoveryResponse> responses = discoveryService.getCandidates(userId, minDistance, maxDistance);
        return ResponseEntity.ok(responses);
    }

    /** POST /discovery/feedback — Submit like/dislike feedback on a candidate. Returns 201 Created. */
    @PostMapping("/feedback")
    public ResponseEntity<FeedbackResponse> submitFeedback(
            @RequestParam @NotBlank String userId,
            @RequestBody FeedbackRequest body
    ) {
        FeedbackResponse result = discoveryService.submitFeedback(
                userId,
                body.getTargetUserId(),
                body.getAction()
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }
}
