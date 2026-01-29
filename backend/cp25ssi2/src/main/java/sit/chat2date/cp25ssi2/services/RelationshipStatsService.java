package sit.chat2date.cp25ssi2.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.dto.RelationshipBarDTO;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.RelationshipStats;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceptions.ConflictException;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.MatchRepository;
import sit.chat2date.cp25ssi2.repositories.RelationshipStatsRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.util.Optional;

@Service
public class RelationshipStatsService {

    @Autowired
    private RelationshipStatsRepository relationshipStatsRepository;
    @Autowired
    private MatchRepository matchRepository;
    @Autowired
    private UserRepository userRepository;

    public ResponseEntity<RelationshipBarDTO> getRelationshipBarByRoomId(String roomIdStr) {
        int roomId = Integer.valueOf(roomIdStr);
        Optional<RelationshipStats> relationshipStats = relationshipStatsRepository.findByRoomId(roomId);
        RelationshipBarDTO relationshipBarDTO = new RelationshipBarDTO();
        relationshipBarDTO.setRoomId(roomId);
        relationshipBarDTO.setRelationship_score(relationshipStats.get().getScore());
        return ResponseEntity.ok(relationshipBarDTO);
    }

    public RelationshipStats createRelationshipBar(String roomIdStr, String token) {
        int roomId = 0;
        try {
            roomId = Integer.parseInt(roomIdStr);
        }catch (Exception e) {
            throw new BadRequestException("Invalid room ID");
        }

        Optional<User> user;
        DecodedJWT jwt = JWT.decode(token);
        String sub = jwt.getClaim("sub").asString();
        if (sub.length() == 10) {
            user = userRepository.findByPhoneNumber(sub);
        } else {
            user = userRepository.findByEmail(sub);
        }

        String userId = user.get().getUserId();
        Optional<Match> match = matchRepository.findById(roomId);

        if (match.isEmpty()) {
            throw new NotFoundException("Room id: " + roomId + " not found");
        }

        if (match.get().getUserId1().getUserId() !=  userId && match.get().getUserId2().getUserId() !=  userId) {
            throw new ForbiddenAccessException("Forbidden: cannot access another user's data");
        }

        if (relationshipStatsRepository.findByRoomId(roomId).isPresent()) {
            throw new ConflictException("Room id: " + roomId + " already exists");
        }

        RelationshipStats relationshipStats = new RelationshipStats();
        relationshipStats.setScore(0);
        relationshipStats.setStreakDays(0);
        relationshipStats.setIsFirstMessageBonus(false);
        relationshipStats.setDailyMessageCount(0);
        relationshipStats.setVersion(1);
        return relationshipStatsRepository.save(relationshipStats);
    }

    public RelationshipStats updateRelationshipBar(RelationshipStats relationshipStats, String roomIdStr) {
        Integer roomId = Integer.parseInt(roomIdStr);
        Optional<RelationshipStats> relationshipStatsById = relationshipStatsRepository.findByRoomId(roomId);
        relationshipStatsById.get().setStreakDays(relationshipStats.getStreakDays());
        relationshipStatsById.get().setIsFirstMessageBonus(relationshipStats.getIsFirstMessageBonus());
        relationshipStatsById.get().setDailyMessageCount(relationshipStats.getDailyMessageCount());
        relationshipStatsById.get().setScore(relationshipStats.getScore());
        relationshipStatsById.get().setDailyDate(relationshipStats.getDailyDate());
        relationshipStatsById.get().setVersion(relationshipStats.getVersion()+1);
        return relationshipStatsRepository.save(relationshipStatsById.get());
    }
}
