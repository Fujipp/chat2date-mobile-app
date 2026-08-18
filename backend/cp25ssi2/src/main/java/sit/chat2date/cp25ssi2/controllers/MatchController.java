package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.MatchListResponse;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.UnauthorizedAccessException;
import sit.chat2date.cp25ssi2.services.MatchService;

import java.util.Optional;

/**
 * REST controller for match management.
 * Handles listing matched users and unmatching.
 */
@RestController
@RequiredArgsConstructor
public class MatchController {

    private final MatchService matchService;

    /** GET /matches — List all matches for the authenticated user. */
    @GetMapping("/matches")
    public ResponseEntity<MatchListResponse> getMatches(
            @AuthenticationPrincipal Optional<User> userOpt) {
        User user = getAuthenticatedUser(userOpt);
        return ResponseEntity.ok(matchService.getAllMatches(user.getUserId()));
    }

    /** DELETE /unmatch — Unmatch with a partner (soft-delete the match). */
    @DeleteMapping("/unmatch")
    public ResponseEntity<Void> unmatch(
            @AuthenticationPrincipal Optional<User> userOpt,
            @RequestParam String roomId,
            @RequestParam String partnerId) {
        User user = getAuthenticatedUser(userOpt);
        matchService.unmatch(user.getUserId(), roomId, partnerId);
        return ResponseEntity.ok().build();
    }

    private User getAuthenticatedUser(Optional<User> userOpt) {
        return userOpt.orElseThrow(() -> new UnauthorizedAccessException("User not found"));
    }
}
