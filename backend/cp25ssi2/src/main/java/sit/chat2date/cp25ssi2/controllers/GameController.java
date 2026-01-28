package sit.chat2date.cp25ssi2.controllers;

import jakarta.persistence.criteria.CriteriaBuilder;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.GameRequest;
import sit.chat2date.cp25ssi2.dto.GameStartResponse;
import sit.chat2date.cp25ssi2.entities.GameQuestion;
import sit.chat2date.cp25ssi2.services.GameService;

import java.util.Map;

@RestController
@RequestMapping("/games")
@Validated
@RequiredArgsConstructor
public class GameController {
    private final GameService gameService;

    @PostMapping("/question")
    public ResponseEntity<GameStartResponse> question(@RequestBody GameRequest roomId) {
        GameStartResponse response  = gameService.createGame(roomId.getRoomId());
        return ResponseEntity.ok(response);
    }
}
