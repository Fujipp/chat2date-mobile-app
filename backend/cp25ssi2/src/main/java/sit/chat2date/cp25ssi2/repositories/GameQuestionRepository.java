package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.GameQuestions;

import java.util.List;

public interface GameQuestionRepository extends JpaRepository<GameQuestions,String> {
    int countByGameId(String gameId);
    List<GameQuestions> findAllByGameId(String gameId);
}
