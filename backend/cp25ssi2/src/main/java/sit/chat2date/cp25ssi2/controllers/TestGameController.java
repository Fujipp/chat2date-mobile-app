package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.services.GameService;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/test")
@RequiredArgsConstructor
public class TestGameController {

    private final SimpMessagingTemplate messagingTemplate;
    private final GameService gameService;

    @PostMapping("/trigger-game/{roomId}")
    public String triggerGame(@PathVariable String roomId) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "GAME_START");
        payload.put("level", 25);

        messagingTemplate.convertAndSend("/topic/games/" + roomId, payload);

        return "Triggered game for room " + roomId;
    }
}