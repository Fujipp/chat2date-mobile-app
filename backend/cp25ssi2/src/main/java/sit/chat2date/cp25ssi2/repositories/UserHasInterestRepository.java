package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.entities.UserHasInterest;
import sit.chat2date.cp25ssi2.entities.UserHasInterestId;

import java.util.List;

public interface UserHasInterestRepository extends JpaRepository<UserHasInterest, Integer> {
    List<UserHasInterest> findAllByUser_UserId(String userId);
    void deleteAllByUser(User user);
}
