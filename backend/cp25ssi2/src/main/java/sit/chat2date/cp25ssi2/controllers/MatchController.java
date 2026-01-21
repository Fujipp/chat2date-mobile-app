package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.MatchListResponse;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.services.MatchService;

import java.util.Optional;

@RestController
@RequestMapping("")
@RequiredArgsConstructor
public class MatchController {

    private final MatchService matchService;

    /**
     * GET /api/v1/matches - Get all matches for current user
     */
    @GetMapping("/matches")
    public ResponseEntity<MatchListResponse> getAllMatches(
            @AuthenticationPrincipal Optional<User> userOpt) {
        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        MatchListResponse response = matchService.getAllMatches(user.getUserId());
        return ResponseEntity.ok(response);
    }

    /**
     * DELETE /api/v1/unmatch - Unmatch with a user (soft delete)
     */
    @DeleteMapping("/unmatch")
    public ResponseEntity<Void> unmatch(
            @AuthenticationPrincipal Optional<User> userOpt,
            @RequestParam String roomId,
            @RequestParam String partnerId) {
        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        matchService.unmatch(user.getUserId(), roomId, partnerId);
        return ResponseEntity.ok().build();
    }
}
