package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.entities.UserHasInterest;
import sit.chat2date.cp25ssi2.entities.UserHasTag;

import java.util.List;

public interface UserHasTagRepository extends JpaRepository<UserHasTag, Integer> {
    List<UserHasTag> findAllByUser_UserId(String userId);
    void deleteAllByUser(User user);
}
