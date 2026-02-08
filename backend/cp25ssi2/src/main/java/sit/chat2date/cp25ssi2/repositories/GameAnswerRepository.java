package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.GameAnswers;

import java.util.List;

public interface GameAnswerRepository extends JpaRepository<GameAnswers, Long> {
    @Query("SELECT CASE WHEN COUNT(a) > 0 THEN true ELSE false END FROM GameAnswers a WHERE a.userId = :userId AND a.question.questionId = :questionId")
    boolean existsByUserIdAndQuestionId(@Param("userId") String userId, @Param("questionId") String questionId);

    @Query("SELECT COUNT(a) FROM GameAnswers a WHERE a.gameSessions.gameId = :gameId")
    int countByGameId(@Param("gameId") String gameId);

    @Query("SELECT COUNT(a) FROM GameAnswers a WHERE a.gameSessions.gameId = :gameId AND a.userId = :userId")
    int countByGameIdAndUserId(@Param("gameId") String gameId, @Param("userId") String userId);

    @Query("SELECT a.question.questionId FROM GameAnswers a WHERE a.userId = :userId AND a.gameSessions.gameId = :gameId")
    List<String> findQuestionIdsByUserIdAndGameId(@Param("userId") String userId, @Param("gameId") String gameId);

    int countByGameIdAndUserIdAndIsCorrect(String gameId, String userId, Boolean isCorrect);
}