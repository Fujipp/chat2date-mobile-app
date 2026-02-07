package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.*;
import sit.chat2date.cp25ssi2.services.GameService;

@RestController
@RequestMapping("/games")
@Validated
@RequiredArgsConstructor
public class GameController {
    private final GameService gameService;

    @PostMapping("/question")
    public ResponseEntity<GameStartResponse> question(@RequestBody GameRequest roomId,@RequestAttribute("userId") String userId) {
        GameStartResponse response  = gameService.createGame(roomId.getRoomId(),userId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/ready/{gameId}")
    public void ready(@PathVariable String gameId,@RequestAttribute("userId") String userId) {
        gameService.playerReady(gameId,userId);
    }

    @PostMapping("/answer")
    public ResponseEntity<GameAnswerResponse> answer(@RequestBody GameAnswerRequest request,@RequestAttribute("userId") String userId) {
        GameAnswerResponse response  = gameService.answerQuestion(request,userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/check/{roomId}")
    public ResponseEntity<GameCheckResponse> checkGame(@PathVariable Integer roomId,@RequestAttribute("userId") String userId) {
        return ResponseEntity.ok(gameService.checkGameStatus(roomId,userId));
    }

    @GetMapping("/{gameId}")
    public ResponseEntity<GameResumeResponse> getGame(
            @PathVariable String gameId,
            @RequestAttribute("userId") String userId
    ) {
        return ResponseEntity.ok(gameService.getGameInfo(gameId, userId));
    }

    @PostMapping("/timeout/{gameId}")
    public ResponseEntity<Void> reportTimeout(@PathVariable String gameId) {
        gameService.gameTimeout(gameId);
        return ResponseEntity.ok().build();
    }
}
