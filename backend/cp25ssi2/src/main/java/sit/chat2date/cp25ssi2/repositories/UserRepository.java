package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.User;

public interface UserRepository extends JpaRepository<User, Integer> {
    User findByCid(String cid);

}