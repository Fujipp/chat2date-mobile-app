package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.entities.UserHasInterest;

import java.util.List;

public interface UserHasInterestRepository extends JpaRepository<UserHasInterest, Integer> {
    List<UserHasInterest> findByUserUser(User user);
    void deleteByUserUser(User user);
}
