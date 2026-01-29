package sit.chat2date.cp25ssi2.controllers;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.RelationshipBarDTO;
import sit.chat2date.cp25ssi2.entities.RelationshipStats;
import sit.chat2date.cp25ssi2.exceptions.TooManyRequestException;
import sit.chat2date.cp25ssi2.services.NotificationService;
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
    @Autowired
    private StringRedisTemplate redis;

    @GetMapping("/{roomId}")
    public ResponseEntity<RelationshipBarDTO> getRelationshipBarByRoomId(@PathVariable String roomId) {
        return relationshipStatsService.getRelationshipBarByRoomId(roomId);
    }

    @PostMapping("")
    public RelationshipStats createRelationshipStats(@RequestBody Map<String, Object> relationshipStats, @RequestHeader("Authorization") String authHeader) {
        String token = null;
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            token = authHeader.substring(7);
        }
        String roomId = (String) relationshipStats.get("roomId");

        return relationshipStatsService.createRelationshipBar(roomId, token);
    }

    @PutMapping("/{roomId}")
    public RelationshipStats updateRelationshipStats(@Valid @RequestBody RelationshipStats relationshipStats, @PathVariable String roomId) {
        String key = "rate_limit:relationship:" + roomId;

        if (redis.hasKey(key)) {
            long waitSec = Optional.ofNullable(redis.getExpire(key, TimeUnit.SECONDS)).orElse(10L);

            throw new TooManyRequestException("This roomId: "+ roomId +" update too many! Waiting to update "  + waitSec + " วินาที");
        }

        redis.opsForValue().set(key, "locked", 10, TimeUnit.SECONDS);

        return relationshipStatsService.updateRelationshipBar(relationshipStats, roomId);
    }
}
