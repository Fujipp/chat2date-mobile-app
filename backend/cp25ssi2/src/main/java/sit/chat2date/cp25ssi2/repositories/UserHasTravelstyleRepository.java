package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.entities.UserHasTravelstyle;

import java.util.List;

public interface UserHasTravelstyleRepository extends JpaRepository<UserHasTravelstyle, Integer> {
    List<UserHasTravelstyle> findByUserUser(User user);
    void deleteByUserUser(User user);
}
