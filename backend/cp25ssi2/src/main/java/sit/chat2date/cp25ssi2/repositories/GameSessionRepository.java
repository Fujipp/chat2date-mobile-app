package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.GameSessions;
import sit.chat2date.cp25ssi2.enums.GameSessionStatus;

import java.util.List;
import java.util.Optional;

public interface GameSessionRepository extends JpaRepository<GameSessions,String> {
    Optional<GameSessions> findTopByRoomIdOrderByCreatedAtDesc(String roomId);

    boolean existsByRoomIdAndStatus(String roomId, GameSessionStatus status);

    List<GameSessions> findAllByRoomId(String roomId);
}
