package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.GameAnswerRequest;
import sit.chat2date.cp25ssi2.dto.GameAnswerResponse;
import sit.chat2date.cp25ssi2.dto.GameRequest;
import sit.chat2date.cp25ssi2.dto.GameStartResponse;
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

    @PostMapping("/answer")
    public ResponseEntity<GameAnswerResponse> answer(@RequestBody GameAnswerRequest request,@RequestAttribute("userId") String userId) {
        GameAnswerResponse response  = gameService.answerQuestion(request,userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
