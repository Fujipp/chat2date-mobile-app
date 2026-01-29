package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.GameQuestions;

public interface GameQuestionRepository extends JpaRepository<GameQuestions,String> {
    int countByGameId(String gameId);
}
