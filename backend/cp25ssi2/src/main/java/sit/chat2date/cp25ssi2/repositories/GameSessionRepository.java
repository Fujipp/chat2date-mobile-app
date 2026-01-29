package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.GameSessions;

public interface GameSessionRepository extends JpaRepository<GameSessions,String> {
}
