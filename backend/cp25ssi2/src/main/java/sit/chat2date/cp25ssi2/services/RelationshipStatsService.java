package sit.chat2date.cp25ssi2.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.dto.RelationshipBarDTO;
import sit.chat2date.cp25ssi2.dto.RelationshipUpdateDTO;
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

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
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
        Optional<RelationshipStats> relationshipStats = relationshipStatsRepository
                .findByRoomId(String.valueOf(roomId));
        RelationshipBarDTO relationshipBarDTO = new RelationshipBarDTO();
        relationshipBarDTO.setRoomId(roomId);
        relationshipBarDTO.setRelationship_score(relationshipStats.get().getScore());
        return ResponseEntity.ok(relationshipBarDTO);
    }

    @Transactional
    public RelationshipStats createRelationshipBar(String roomIdStr, String token) {
        int roomId = 0;
        try {
            roomId = Integer.parseInt(roomIdStr);
        } catch (Exception e) {
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

        if (match.get().getUserId1().getUserId() != userId && match.get().getUserId2().getUserId() != userId) {
            throw new ForbiddenAccessException("Forbidden: cannot access another user's data");
        }

        Optional<RelationshipStats> relationshipById = relationshipStatsRepository.findById(String.valueOf(roomId));

        if (relationshipById.isPresent()) {
            throw new ConflictException("Room id: " + roomId + " already exists");
        }

        ZonedDateTime localDate = ZonedDateTime.now(ZoneId.of("Asia/Bangkok"));

        RelationshipStats relationshipStats = new RelationshipStats();
        relationshipStats.setRelationshipId(roomIdStr);
        relationshipStats.setScore(0);
        relationshipStats.setStreakDays(0);
        relationshipStats.setIsFirstMessageBonus(false);
        relationshipStats.setDailyMessageCount(0);
        relationshipStats.setVersion(0);
        relationshipStats.setDailyDate(localDate.toLocalDate());

        return relationshipStatsRepository.saveAndFlush(relationshipStats);
    }

    public RelationshipStats updateRelationshipBar(RelationshipUpdateDTO relationshipStats, String roomIdStr) {
        Integer roomId = Integer.parseInt(roomIdStr);
        Optional<RelationshipStats> relationshipStatsById = relationshipStatsRepository
                .findByRoomId(String.valueOf(roomId));
        int score = 0;

        LocalDate today = LocalDate.now(ZoneId.of("Asia/Bangkok"));

        if (relationshipStatsById.isPresent()) {
            if (!relationshipStatsById.get().getVersion().equals(relationshipStats.getVersion())) {
                throw new ConflictException("Version mismatch");
            }

            if (!today.equals(relationshipStatsById.get().getDailyDate())) {
                long daysBetween = java.time.temporal.ChronoUnit.DAYS
                        .between(relationshipStatsById.get().getDailyDate(), today);

                if (daysBetween > 0) {
                    int currentStreak = relationshipStatsById.get().getStreakDays();

                    if (daysBetween > 1) {
                        int penaltyDays = (int) (daysBetween - 1);

                        if (currentStreak > 0) {
                            relationshipStatsById.get().setStreakDays(-penaltyDays);
                        } else {
                            relationshipStatsById.get().setStreakDays(currentStreak - penaltyDays);
                        }
                    } else {
                        relationshipStatsById.get().setStreakDays(0);
                    }

                    int updatedStreak = relationshipStatsById.get().getStreakDays();
                    if (updatedStreak <= 0) {
                        score -= (int) daysBetween;
                        ; // ลดพื้นฐาน 1 คะแนนเมื่อ streak หลุด

                        // ใช้ <= เพื่อให้ครอบคลุมกรณีที่วันหายไปเยอะๆ แล้ว streak กระโดดข้ามขั้น
                        if (updatedStreak <= -30) {
                            Optional<Match> match = matchRepository.findById(roomId);
                            if (match.isPresent()) {
                                matchRepository.delete(match.get());
                                return null;
                            }
                        }
                        if (updatedStreak <= -10) {
                            score -= 25;
                        }
                        if (updatedStreak <= -7) {
                            score -= 10;
                        }
                        if (updatedStreak <= -3) {
                            score -= 5;
                        }
                    }
                }
                relationshipStatsById.get().setDailyMessageCount(0);
                relationshipStatsById.get().setDailyDate(today);
            }

            int oldMessageCount = relationshipStatsById.get().getDailyMessageCount();

            if (oldMessageCount < 30) {
                if (oldMessageCount == 0 && relationshipStats.getDaily_message_count() >= 1) {
                    if (relationshipStatsById.get().getIsFirstMessageBonus() == false) {
                        relationshipStatsById.get().setIsFirstMessageBonus(true);
                        score += 5;
                    }
                    relationshipStatsById.get().setStreakDays(relationshipStatsById.get().getStreakDays() + 1);
                    switch (relationshipStatsById.get().getStreakDays()) {
                        case 3:
                            score += 7;
                            break;
                        case 7:
                            score += 10;
                            break;
                        case 10:
                            score += 20;
                            break;
                        default:
                            break;
                    }
                }
                int newMessageCount = oldMessageCount + relationshipStats.getDaily_message_count();
                relationshipStatsById.get().setDailyMessageCount(newMessageCount);
                if (newMessageCount >= 30) {
                    score += 8;
                }
            }
        }

        relationshipStatsById.get().setScore(relationshipStatsById.get().getScore() + score);
        relationshipStatsById.get().setVersion(relationshipStats.getVersion() + 1);
        return relationshipStatsRepository.save(relationshipStatsById.get());
    }
}
