package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.entities.RelationshipStats;
import sit.chat2date.cp25ssi2.services.RelationshipStatsService;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/relationship")
@RequiredArgsConstructor
public class RelationshipStatsController {

    private final RelationshipStatsService relationshipStatsService;
    private final SimpMessagingTemplate simpMessagingTemplate;

    @GetMapping("/{roomId}")
    public ResponseEntity<Optional<RelationshipStats>> getRelationshipBarByRoomId(@PathVariable String roomId) {
        return relationshipStatsService.getRelationshipBarByRoomId(roomId);
    }

    @PostMapping("")
    @ResponseStatus(HttpStatus.CREATED)
    public RelationshipStats createRelationshipStats(@RequestBody Map<String, Object> relationshipStats, @RequestHeader("Authorization") String authHeader) {
        String token = null;
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            token = authHeader.substring(7);
        }
        String roomId = (String) relationshipStats.get("roomId");

        return relationshipStatsService.createRelationshipBar(roomId, token);
    }

    @PutMapping("/{roomId}")
    public RelationshipStats updateRelationshipStats(@PathVariable String roomId) {
        RelationshipStats updatedStats = relationshipStatsService.updateRelationshipBar(roomId);
        simpMessagingTemplate.convertAndSend("/topic/relationship/" + roomId, updatedStats);

        return updatedStats;
    }

    @GetMapping("/check-noti/{roomId}")
    public String checkNoti(@PathVariable String roomId,// "BEFORE" หรือ "UNMATCH"
            @RequestHeader("Authorization") String authHeader) {

        String token = null;
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            token = authHeader.substring(7);
        }// แยก helper logic ออกมาดึง userId

        return relationshipStatsService.checkNotificationToDisplay(roomId, token);

    }

    @PatchMapping("/{roomId}/trigger-notification")
    public ResponseEntity<RelationshipStats> triggerNotificationUpdate(
            @PathVariable String roomId,
            @RequestHeader("Authorization") String authHeader) {

        String token = null;
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            token = authHeader.substring(7);
        }

        RelationshipStats updatedStats = relationshipStatsService.processNotificationLogic(roomId, token);

        return ResponseEntity.ok(updatedStats);
    }
}
