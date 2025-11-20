package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.User;

public interface MatchRepository extends JpaRepository<Match, Integer> {

    boolean existsByUserId1AndUserId2(User user1, User user2);
}
