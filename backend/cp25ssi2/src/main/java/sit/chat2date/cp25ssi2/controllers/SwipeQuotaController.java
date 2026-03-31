package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.SwipeQuotaResponse;
import sit.chat2date.cp25ssi2.services.SwipeQuotaService;

/**
 * REST controller for swipe quota management.
 * Tracks daily swipe limits and processes swipe deductions.
 */
@RestController
@RequestMapping("/swipe")
@RequiredArgsConstructor
public class SwipeQuotaController {

    private final SwipeQuotaService swipeQuotaService;

    /** GET /swipe/check-status — Get the current user's remaining swipe quota for today. */
    @GetMapping("/check-status")
    public ResponseEntity<SwipeQuotaResponse> checkStatus(@RequestHeader("Authorization") String accessToken) {
        return ResponseEntity.ok(swipeQuotaService.getQuotaStatus(accessToken));
    }

    /** PUT /swipe/process — Deduct one swipe from the user's daily quota. */
    @PutMapping("/process")
    public ResponseEntity<SwipeQuotaResponse> processSwipe(@RequestHeader("Authorization") String accessToken) {
        return ResponseEntity.ok(swipeQuotaService.processSwipe(accessToken));
    }
}
