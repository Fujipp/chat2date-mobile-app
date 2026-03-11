package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.PostTripReviewRequest;
import sit.chat2date.cp25ssi2.services.PostTripReviewService;

import java.util.Map;

@RestController
@RequestMapping("/dates/reviews")
@RequiredArgsConstructor
public class DateReviewController {

    private final PostTripReviewService reviewService;

    @GetMapping("/{appointmentId}")
    public ResponseEntity<?> checkReview(
            @RequestAttribute("userId") String userId,
            @PathVariable Integer appointmentId) {

        boolean isReviewed = reviewService.checkReviewStatus(userId, appointmentId);

        return ResponseEntity.ok(Map.of(
                "isReviewed", isReviewed
        ));
    }

    @PostMapping("/{appointmentId}")
    public ResponseEntity<?> submitReview(
            @RequestAttribute("userId") String userId,
            @PathVariable Integer appointmentId,
            @RequestBody PostTripReviewRequest req) {

        reviewService.submitReview(userId, appointmentId, req);

        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "message", "บันทึกผลการประเมินเรียบร้อยแล้ว"
        ));
    }
}