package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.UserPhoto;

import java.util.List;

public interface UserPhotoRepository extends JpaRepository<UserPhoto, Integer> {
    UserPhoto findByUser_UserId(String userId);
    List<UserPhoto> findAllByUser_UserId(String userId);
}
