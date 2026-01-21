package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.ChatAccessLog;
import sit.chat2date.cp25ssi2.enums.ChatAccessActionType;

import java.util.List;
import java.util.Optional;

public interface ChatAccessLogRepository extends JpaRepository<ChatAccessLog, Long> {

    @Query("SELECT c FROM ChatAccessLog c WHERE c.roomId = :roomId AND c.userId = :userId ORDER BY c.createdAt DESC LIMIT 1")
    Optional<ChatAccessLog> findLatestByRoomIdAndUserId(@Param("roomId") Integer roomId,
            @Param("userId") String userId);

    @Query("SELECT c FROM ChatAccessLog c WHERE c.roomId = :roomId AND c.createdAt = " +
            "(SELECT MAX(c2.createdAt) FROM ChatAccessLog c2 WHERE c2.roomId = c.roomId AND c2.userId = c.userId)")
    List<ChatAccessLog> findLatestStatusByRoomId(@Param("roomId") Integer roomId);

    boolean existsByRoomIdAndUserIdAndActionType(Integer roomId, String userId, ChatAccessActionType actionType);
}
