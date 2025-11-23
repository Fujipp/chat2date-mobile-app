package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.UserPhoto;

import java.util.List;

public interface UserPhotoRepository extends JpaRepository<UserPhoto, Integer> {
    UserPhoto findByUser_UserId(String userId);
    List<UserPhoto> findAllByUser_UserId(String userId);
    @Query("SELECT up.attributes FROM UserPhoto up WHERE up.user.userId = :userId")
    String findAttributesJsonByUser_UserId(@Param("userId") String userId);

}
