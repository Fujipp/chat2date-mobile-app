package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.User;

import java.util.List;
import java.util.Optional;

public interface MatchRepository extends JpaRepository<Match, Integer> {

    boolean existsByUserId1AndUserId2(User user1, User user2);

    @Query("SELECT m FROM Match m WHERE m.userId1 = :user OR m.userId2 = :user ORDER BY m.createdAt DESC")
    List<Match> findAllByUser(@Param("user") User user);

    @Query("SELECT m FROM Match m WHERE m.id = :matchId AND (m.userId1.userId = :userId OR m.userId2.userId = :userId)")
    Optional<Match> findByIdAndUserId(@Param("matchId") Integer matchId, @Param("userId") String userId);

    @Query("SELECT m FROM Match m WHERE (m.userId1.userId = :userId1 AND m.userId2.userId = :userId2) OR (m.userId1.userId = :userId2 AND m.userId2.userId = :userId1)")
    Optional<Match> findByUsers(@Param("userId1") String userId1, @Param("userId2") String userId2);
}
