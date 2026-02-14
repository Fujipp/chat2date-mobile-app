package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.RelationshipStats;
import sit.chat2date.cp25ssi2.exceptions.TooManyRequestException;
import sit.chat2date.cp25ssi2.services.RelationshipStatsService;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping("/relationship")
@RequiredArgsConstructor
public class RelationshipStatsController {
    @Autowired
    private RelationshipStatsService relationshipStatsService;

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
        return relationshipStatsService.updateRelationshipBar(roomId);
    }

    @GetMapping("/check-noti/{roomId}")
    public String checkNoti(
            @PathVariable String roomId,// "BEFORE" หรือ "UNMATCH"
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
