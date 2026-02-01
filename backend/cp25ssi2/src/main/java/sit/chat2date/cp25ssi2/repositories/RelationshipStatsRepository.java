package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.RelationshipStats;

import java.util.Optional;

public interface RelationshipStatsRepository extends JpaRepository<RelationshipStats, String> {

    @Query("SELECT r FROM RelationshipStats r WHERE r.relationshipId = :roomId")
    Optional<RelationshipStats> findByRoomId(@Param("roomId") String roomId);

    // Overloaded method for Integer roomId (for backward compatibility with
    // GameService)
    default Optional<RelationshipStats> findByRoomId(Integer roomId) {
        return findByRoomId(String.valueOf(roomId));
    }
}
