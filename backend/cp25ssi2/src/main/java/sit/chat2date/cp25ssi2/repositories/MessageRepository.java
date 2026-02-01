package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.Message;

import java.util.List;
import java.util.Optional;

public interface MessageRepository extends JpaRepository<Message, Long> {

    Page<Message> findByRoomIdOrderByCreatedAtDesc(Integer roomId, Pageable pageable);

    Optional<Message> findFirstByRoomIdOrderByCreatedAtDesc(Integer roomId);

    @Query("SELECT COUNT(m) FROM Message m WHERE m.roomId = :roomId AND m.senderId != :userId AND m.isRead = false")
    Integer countUnreadMessages(@Param("roomId") Integer roomId, @Param("userId") String userId);

    @Modifying
    @Query("UPDATE Message m SET m.isRead = true WHERE m.roomId = :roomId AND m.senderId != :userId AND m.isRead = false")
    void markMessagesAsRead(@Param("roomId") Integer roomId, @Param("userId") String userId);

    List<Message> findLast50ByRoomIdOrderByCreatedAtDesc(Integer roomId);

    @Query(value = "SELECT * FROM messages " +
            "WHERE roomId = :roomId " +
            "AND DATE(createdAt) = CURRENT_DATE " +
            "AND CHAR_LENGTH(TRIM(message)) >= 3 " + // เพิ่มเงื่อนไข 3 ตัวอักษรขึ้นไป
            "ORDER BY createdAt ASC", nativeQuery = true)
    List<Message> findTodayMessagesByRoom(@Param("roomId") Integer roomId);
}
