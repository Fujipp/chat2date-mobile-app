package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.entities.UserHasLifestyle;

import java.util.List;

public interface UserHasLifestyleRepository extends JpaRepository<UserHasLifestyle, Integer> {
    List<UserHasLifestyle> findAllByUser_UserId(String userId);
    void deleteAllByUser(User user);
}
