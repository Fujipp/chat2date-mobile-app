package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.ChatAccessLog;
import sit.chat2date.cp25ssi2.enums.ChatAccessActionType;

import java.util.List;
import java.util.Optional;

public interface ChatAccessLogRepository extends JpaRepository<ChatAccessLog, Long> {

        /**
         * Find existing access record by roomId and userId
         */
        Optional<ChatAccessLog> findByRoomIdAndUserId(Integer roomId, String userId);

        @Query("SELECT c FROM ChatAccessLog c WHERE c.roomId = :roomId AND c.userId = :userId ORDER BY c.updatedAt DESC LIMIT 1")
        Optional<ChatAccessLog> findLatestByRoomIdAndUserId(@Param("roomId") Integer roomId,
                        @Param("userId") String userId);

        @Query("SELECT c FROM ChatAccessLog c WHERE c.roomId = :roomId")
        List<ChatAccessLog> findAllByRoomId(@Param("roomId") Integer roomId);

        boolean existsByRoomIdAndUserIdAndActionType(Integer roomId, String userId, ChatAccessActionType actionType);
}
