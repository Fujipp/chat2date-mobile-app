package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.GameAnswerRequest;
import sit.chat2date.cp25ssi2.dto.GameAnswerResponse;
import sit.chat2date.cp25ssi2.dto.GameCheckResponse;
import sit.chat2date.cp25ssi2.dto.GameRequest;
import sit.chat2date.cp25ssi2.dto.GameResumeResponse;
import sit.chat2date.cp25ssi2.dto.GameStartResponse;
import sit.chat2date.cp25ssi2.services.GameService;

/**
 * REST controller for the in-chat mini-game.
 * Handles game creation, readiness, answering, status checks, and timeouts.
 */
@RestController
@RequestMapping("/games")
@Validated
@RequiredArgsConstructor
public class GameController {

    private final GameService gameService;

    // ────────────────────────────────────────────────────────────────────────
    // Game Lifecycle
    // ────────────────────────────────────────────────────────────────────────

    /** POST /games/question — Create a new game session for a room. */
    @PostMapping("/question")
    public ResponseEntity<GameStartResponse> createGame(
            @RequestBody GameRequest request,
            @RequestAttribute("userId") String userId) {
        return ResponseEntity.ok(gameService.createGame(request.getRoomId(), userId));
    }

    /** POST /games/ready/{gameId} — Mark the current player as ready. */
    @PostMapping("/ready/{gameId}")
    public void markReady(
            @PathVariable String gameId,
            @RequestAttribute("userId") String userId) {
        gameService.playerReady(gameId, userId);
    }

    /** POST /games/answer — Submit an answer for a game question. Returns 201 Created. */
    @PostMapping("/answer")
    public ResponseEntity<GameAnswerResponse> submitAnswer(
            @RequestBody GameAnswerRequest request,
            @RequestAttribute("userId") String userId) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(gameService.answerQuestion(request, userId));
    }

    // ────────────────────────────────────────────────────────────────────────
    // Game Status
    // ────────────────────────────────────────────────────────────────────────

    /** GET /games/check/{roomId} — Check if there is an active or recent game for a room. */
    @GetMapping("/check/{roomId}")
    public ResponseEntity<GameCheckResponse> checkGameStatus(
            @PathVariable Integer roomId,
            @RequestAttribute("userId") String userId) {
        return ResponseEntity.ok(gameService.checkGameStatus(roomId, userId));
    }

    /** GET /games/{gameId} — Get game info for resuming a game session. */
    @GetMapping("/{gameId}")
    public ResponseEntity<GameResumeResponse> getGameInfo(
            @PathVariable String gameId,
            @RequestAttribute("userId") String userId) {
        return ResponseEntity.ok(gameService.getGameInfo(gameId, userId));
    }

    /** POST /games/timeout/{gameId} — Report that a game session has timed out. */
    @PostMapping("/timeout/{gameId}")
    public ResponseEntity<Void> reportTimeout(@PathVariable String gameId) {
        gameService.gameTimeout(gameId);
        return ResponseEntity.ok().build();
    }
}
