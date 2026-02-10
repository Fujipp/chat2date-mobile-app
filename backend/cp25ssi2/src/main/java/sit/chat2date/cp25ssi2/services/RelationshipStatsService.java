package sit.chat2date.cp25ssi2.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.Message;
import sit.chat2date.cp25ssi2.entities.RelationshipStats;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceptions.ConflictException;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.MatchRepository;
import sit.chat2date.cp25ssi2.repositories.MessageRepository;
import sit.chat2date.cp25ssi2.repositories.RelationshipStatsRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.time.*;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;

@Service
public class RelationshipStatsService {

    @Autowired
    private RelationshipStatsRepository relationshipStatsRepository;
    @Autowired
    private MatchRepository matchRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private MessageRepository messageRepository;
    @Autowired
    private GameService gameService;

    public ResponseEntity<Optional<RelationshipStats>> getRelationshipBarByRoomId(String roomIdStr) {
        int roomId = Integer.parseInt(roomIdStr);
        Optional<RelationshipStats> relationshipStats = relationshipStatsRepository
                .findByRoomId(roomId);
        return ResponseEntity.ok(relationshipStats);
    }

    @Transactional
    public RelationshipStats createRelationshipBar(String roomIdStr, String token) {
        int roomId = 0;
        try {
            roomId = Integer.parseInt(roomIdStr);
        } catch (Exception e) {
            throw new BadRequestException("Invalid room ID: " + roomIdStr);
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

        Optional<RelationshipStats> relationshipById = relationshipStatsRepository.findById(roomId);

        if (relationshipById.isPresent()) {
            throw new ConflictException("Room id: " + roomId + " already exists");
        }

        ZonedDateTime localDate = ZonedDateTime.now(ZoneId.of("Asia/Bangkok"));

        RelationshipStats relationshipStats = new RelationshipStats();
        relationshipStats.setRelationshipId(roomId);
        relationshipStats.setScore(0);
        relationshipStats.setStreakDays(0);
        relationshipStats.setIsFirstMessageBonus(false);
        relationshipStats.setDailyMessageCount(0);
        relationshipStats.setIsDailyMessagesBonus(false);
        relationshipStats.setDailyDate(localDate.toLocalDate());

        return relationshipStatsRepository.saveAndFlush(relationshipStats);
    }

    public RelationshipStats updateRelationshipBar(String roomIdStr) {
        Integer roomId = Integer.parseInt(roomIdStr);
        Optional<RelationshipStats> relationshipStatsById = relationshipStatsRepository
                .findByRoomId(roomId);
        int score = 0;

        Optional<Match> matchById = matchRepository.findById(roomId);
        if (matchById.isEmpty()) {
            throw new NotFoundException("Room id: " + roomId + " not found");
        }
        long daysBetween = 0;

        LocalDate today = LocalDate.now(ZoneId.of("Asia/Bangkok"));

        Optional<Message> lastMessage = messageRepository.findFirstByRoomIdOrderByCreatedAtDesc(roomId);
        daysBetween = lastMessage
                .map(message -> ChronoUnit.DAYS.between(message.getCreatedAt().toLocalDate(), today))
                .orElseGet(() -> ChronoUnit.DAYS.between(matchById.get().getCreatedAt().toLocalDate(), today));

        if (relationshipStatsById.isPresent()) {
            if (!today.equals(relationshipStatsById.get().getDailyDate())) {
                if (daysBetween > 0) {
                    int currentStreak = relationshipStatsById.get().getStreakDays();
                    if (daysBetween > 1) {
                        int penaltyDays = (int) (daysBetween);
                        int newStreak;
                        if (currentStreak > 0) {
                            newStreak = -(penaltyDays - 1);
                        } else {
                            newStreak = currentStreak - penaltyDays;
                        }
                        relationshipStatsById.get().setStreakDays(newStreak);
                    }

                    int updatedStreak = relationshipStatsById.get().getStreakDays();
                    if (updatedStreak <= 0 && relationshipStatsById.get().getDailyMessageCount() == 0) {
                        score -= (int) daysBetween;

                        if (!relationshipStatsById.get().getIsFirstMessageBonus() && updatedStreak <= -7) {
                            Optional<Match> match = matchRepository.findById(roomId);
                            if (match.isPresent()) {
                                match.get().setDeletedAt(LocalDateTime.now());
                                match.get().setDeleteFlag(true);
                                matchRepository.saveAndFlush(match.get());
                                return null;
                            }
                        }

                        if (updatedStreak <= -30) {
                            Optional<Match> match = matchRepository.findById(roomId);
                            if (match.isPresent()) {
                                match.get().setDeletedAt(LocalDateTime.now());
                                match.get().setDeleteFlag(true);
                                matchRepository.saveAndFlush(match.get());
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

                if (relationshipStatsById.get().getDailyMessageCount() > 0 && daysBetween == 1) {
                    relationshipStatsById.get().setStreakDays(relationshipStatsById.get().getStreakDays() + 1);
                } else if (relationshipStatsById.get().getDailyMessageCount() == 0 && daysBetween == 1) {
                    if (relationshipStatsById.get().getStreakDays() > 0) {
                        relationshipStatsById.get().setStreakDays(0);
                    } else {
                        relationshipStatsById.get().setStreakDays(relationshipStatsById.get().getStreakDays() - 1);
                    }
                }

                relationshipStatsById.get().setDailyMessageCount(0);
                relationshipStatsById.get().setDailyDate(today);
                relationshipStatsById.get().setIsDailyMessagesBonus(false);
            }

            LocalDateTime start = today.atStartOfDay();
            LocalDateTime end = today.atTime(LocalTime.MAX);

            List<Message> messageList = messageRepository.findTodayMessagesByRoom(roomId, start, end);

            int totalConversationCount = 0;
            String lastSenderId = "";

            for (Message msg : messageList) {
                if (!msg.getSenderId().equals(lastSenderId)) {
                    totalConversationCount++;
                    lastSenderId = msg.getSenderId();
                }
            }

            if (totalConversationCount >= 1) {
                if (relationshipStatsById.get().getIsFirstMessageBonus() == false && totalConversationCount >= 2) {
                    relationshipStatsById.get().setIsFirstMessageBonus(true);
                    score += 5;
                }
                if (relationshipStatsById.get().getStreakDays() < 0) {
                    relationshipStatsById.get().setStreakDays(0);
                }
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
            relationshipStatsById.get().setDailyMessageCount(totalConversationCount);
            if (totalConversationCount >= 30 && relationshipStatsById.get().getIsDailyMessagesBonus() == false) {
                score += 8;
                relationshipStatsById.get().setIsDailyMessagesBonus(true);
            }
            if (relationshipStatsById.get().getScore() + score >= 0) {
                relationshipStatsById.get().setScore(relationshipStatsById.get().getScore() + score);
            } else {
                relationshipStatsById.get().setScore(0);
            }
            RelationshipStats savedStats = relationshipStatsRepository.save(relationshipStatsById.get());
            gameService.checkAndTriggerGame(roomId, savedStats.getScore());
            return relationshipStatsRepository.save(relationshipStatsById.get());
        } else {
            RelationshipStats relationshipStats = new RelationshipStats();
            relationshipStats.setRelationshipId(roomId);
            relationshipStats.setScore(0);
            relationshipStats.setStreakDays(0);
            relationshipStats.setIsFirstMessageBonus(false);
            relationshipStats.setDailyMessageCount(0);
            relationshipStats.setIsDailyMessagesBonus(false);
            relationshipStats.setDailyDate(today);
            return relationshipStatsRepository.saveAndFlush(relationshipStats);
        }
    }
}
