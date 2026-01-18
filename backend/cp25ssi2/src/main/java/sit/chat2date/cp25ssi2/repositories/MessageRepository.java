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

public interface MessageRepository extends JpaRepository<Message, String> {

    Page<Message> findByRoomIdOrderByCreatedAtDesc(String roomId, Pageable pageable);

    List<Message> findByRoomIdOrderByCreatedAtDesc(String roomId);

    Optional<Message> findFirstByRoomIdOrderByCreatedAtDesc(String roomId);

    @Query("SELECT COUNT(m) FROM Message m WHERE m.roomId = :roomId AND m.senderId != :userId AND m.isRead = false")
    Integer countUnreadMessages(@Param("roomId") String roomId, @Param("userId") String userId);

    @Modifying
    @Query("UPDATE Message m SET m.isRead = true WHERE m.roomId = :roomId AND m.senderId != :userId AND m.isRead = false")
    void markMessagesAsRead(@Param("roomId") String roomId, @Param("userId") String userId);
}
