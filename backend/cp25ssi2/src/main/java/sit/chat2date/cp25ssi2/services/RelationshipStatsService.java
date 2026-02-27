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
import sit.chat2date.cp25ssi2.enums.NotifyStatus;
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
        relationshipStats.setNotiBeforeUnmatch(NotifyStatus.NONE);
        relationshipStats.setNotiUnmatch(NotifyStatus.NONE);

        return relationshipStatsRepository.saveAndFlush(relationshipStats);
    }

    @Transactional
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
                .map(message -> ChronoUnit.DAYS.between(message.getCreatedAt().plusHours(7).toLocalDate(), today))
                .orElseGet(() -> ChronoUnit.DAYS.between(matchById.get().getCreatedAt().plusHours(7).toLocalDate(), today));

        int oldStreakDays = 0;

        if (relationshipStatsById.isPresent()) {
            oldStreakDays = relationshipStatsById.get().getStreakDays();
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

                        if (!relationshipStatsById.get().getIsFirstMessageBonus()) {
                            if (updatedStreak > -6) {
                                relationshipStatsById.get().setNotiBeforeUnmatch(NotifyStatus.NONE);
                                relationshipStatsById.get().setNotiUnmatch(NotifyStatus.NONE);
                            }

                        } else {

                            if (updatedStreak > -29) {
                                relationshipStatsById.get().setNotiBeforeUnmatch(NotifyStatus.NONE);
                                relationshipStatsById.get().setNotiUnmatch(NotifyStatus.NONE);
                            }
                        }
                        if (updatedStreak <= -10 && oldStreakDays >= -9) {
                            score -= 25;
                        }
                        if (updatedStreak <= -7 && oldStreakDays >= -6) {
                            score -= 10;
                        }
                        if (updatedStreak <= -3 && oldStreakDays >= -2) {
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

            LocalDateTime start = today.atStartOfDay().minusHours(7);
            LocalDateTime end = today.atTime(LocalTime.MAX).minusHours(7);

            List<Message> messageList = messageRepository.findTodayMessagesByRoom(roomId, start, end);

            int totalConversationCount = 0;
            String lastSenderId = "";

            for (Message msg : messageList) {
                if (!msg.getSenderId().equals(lastSenderId) && !msg.getSenderId().equals("SYSTEM")) {
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
                if ((oldStreakDays != 3 && oldStreakDays != 7 && oldStreakDays != 10) && (relationshipStatsById.get().getStreakDays() == 3 || relationshipStatsById.get().getStreakDays() == 7 || relationshipStatsById.get().getStreakDays() == 10)) {
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
            }
            relationshipStatsById.get().setDailyMessageCount(totalConversationCount);
            if (totalConversationCount >= 30 && relationshipStatsById.get().getIsDailyMessagesBonus() == false) {
                score += 8;
                relationshipStatsById.get().setIsDailyMessagesBonus(true);
            }
            if (relationshipStatsById.get().getScore() + score >= 0) {
                relationshipStatsById.get().setScore(relationshipStatsById.get().getScore() + score);
                int finalScore = relationshipStatsById.get().getScore();

                if (finalScore > 400) {
                    finalScore = 400;
                } else if (finalScore < 0) {
                    finalScore = 0;
                }

                relationshipStatsById.get().setScore(finalScore);
            } else {
                relationshipStatsById.get().setScore(0);
            }

            RelationshipStats savedStats = relationshipStatsRepository.save(relationshipStatsById.get());
            gameService.checkAndTriggerGame(roomId);
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
            relationshipStats.setNotiBeforeUnmatch(NotifyStatus.NONE);
            relationshipStats.setNotiUnmatch(NotifyStatus.NONE);
            return relationshipStatsRepository.saveAndFlush(relationshipStats);
        }
    }

    public String checkNotificationToDisplay(String roomId, String token) {
        RelationshipStats stats = relationshipStatsRepository.findByRoomId(Integer.parseInt(roomId))
                .orElseThrow(() -> new RuntimeException("Stats not found"));

        DecodedJWT jwt = JWT.decode(token);
        String sub = jwt.getClaim("sub").asString();
        User user = (sub.length() == 10) ? userRepository.findByPhoneNumber(sub).get() : userRepository.findByEmail(sub).get();

        Match match = matchRepository.findById(Integer.valueOf(roomId)).get();
        boolean isUser1 = match.getUserId1().getUserId().equals(user.getUserId());
        NotifyStatus mySide = isUser1 ? NotifyStatus.LEFT : NotifyStatus.RIGHT;

        int days = stats.getStreakDays();
        boolean isFirstBonus = stats.getIsFirstMessageBonus();

        // 1. เช็คเงื่อนไข UNMATCH ก่อน (ความสำคัญสูงสุด)
        boolean isTimeForUnmatch = (!isFirstBonus && days <= -7) || (isFirstBonus && days <= -30);
        if (isTimeForUnmatch) {
            NotifyStatus status = stats.getNotiUnmatch();
            // ถ้าเรายังไม่เคยเห็นสถานะ UNMATCH
            if (status != NotifyStatus.BOTH && status != mySide) {
                return "UNMATCH";
            }
        }

        // 2. เช็คเงื่อนไข BEFORE UNMATCH
        boolean isTimeForBefore = (!isFirstBonus && days == -6) || (isFirstBonus && days == -29);
        if (isTimeForBefore) {
            NotifyStatus status = stats.getNotiBeforeUnmatch();
            // ถ้าเรายังไม่เคยเห็นสถานะ BEFORE
            if (status != NotifyStatus.BOTH && status != mySide) {
                return "BEFORE";
            }
        }

        // 3. ถ้าไม่เข้าเงื่อนไขเลย หรือเคยเห็นไปแล้วทั้งคู่
        return "NONE";
    }

    @Transactional
    public RelationshipStats processNotificationLogic(String roomId, String token) {
        RelationshipStats stats = relationshipStatsRepository.findByRoomId(Integer.parseInt(roomId))
                .orElseThrow(() -> new RuntimeException("Stats not found"));

        DecodedJWT jwt = JWT.decode(token);
        String sub = jwt.getClaim("sub").asString();
        User user = (sub.length() == 10) ? userRepository.findByPhoneNumber(sub).get() : userRepository.findByEmail(sub).get();

        Match match = matchRepository.findById(Integer.valueOf(roomId))
                .orElseThrow(() -> new RuntimeException("Match not found"));

        boolean isUser1 = match.getUserId1().getUserId().equals(user.getUserId());
        int days = stats.getStreakDays();
        boolean isFirstBonus = stats.getIsFirstMessageBonus();

        if ((!isFirstBonus && days == -6) || (isFirstBonus && days == -29)) {
            stats.setNotiBeforeUnmatch(calculateNextStatus(stats.getNotiBeforeUnmatch(), isUser1));
        }

        if ((!isFirstBonus && days <= -7) || (isFirstBonus && days <= -30)) {
            NotifyStatus nextStatus = calculateNextStatus(stats.getNotiUnmatch(), isUser1);
            stats.setNotiUnmatch(nextStatus);

            // === ส่วนที่เพิ่ม: ถ้าเป็น BOTH ให้สั่ง Delete Match ทันที ===
            if (nextStatus == NotifyStatus.BOTH) {
                match.setDeletedAt(LocalDateTime.now());
                match.setDeleteFlag(true);
                matchRepository.saveAndFlush(match);
            }
        }

        return relationshipStatsRepository.save(stats);
    }

    private NotifyStatus calculateNextStatus(NotifyStatus current, boolean isUser1) {
        NotifyStatus mySide = isUser1 ? NotifyStatus.LEFT : NotifyStatus.RIGHT;
        NotifyStatus otherSide = isUser1 ? NotifyStatus.RIGHT : NotifyStatus.LEFT;

        if (current == NotifyStatus.BOTH || current == mySide)
            return current; // ถ้าเป็น BOTH หรือฝั่งเราอยู่แล้ว ไม่ต้องเปลี่ยน
        if (current == otherSide) return NotifyStatus.BOTH; // ถ้าอีกฝั่งมีอยู่แล้ว และเรามาเพิ่ม ก็กลายเป็น BOTH
        if (current == NotifyStatus.NONE) return mySide; // ถ้ายังไม่มีใครเลย ก็เริ่มที่ฝั่งเรา

        return current;
    }
}
