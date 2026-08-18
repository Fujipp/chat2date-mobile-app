package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.UserPhoto;

import java.util.List;

public interface UserPhotoRepository extends JpaRepository<UserPhoto, Integer> {
    UserPhoto findByUser_UserId(String userId);

    @Query(value = "SELECT attributes FROM userphoto WHERE userId = :userId LIMIT 1", nativeQuery = true)
    String findAttributesJsonByUser_UserId(@Param("userId") String userId);

    @Query(value = "SELECT base64Card FROM userphoto WHERE userId = :userId LIMIT 1", nativeQuery = true)
    String findBase64CardByUser_UserId(@Param("userId") String userId);

    @Query(value = "SELECT JSON_UNQUOTE(JSON_EXTRACT(attributes, '$.urls[0]')) FROM userphoto WHERE userId = :userId LIMIT 1", nativeQuery = true)
    String findFirstAvatarUrl(@Param("userId") String userId);
}
