package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import sit.chat2date.cp25ssi2.entities.Tag;

import java.util.List;

public interface TagRepository extends JpaRepository<Tag, Integer> {
    @Query(value = """
    SELECT tg.tag
    FROM user_has_tag uht
    JOIN tag tg ON uht.tag_tagId = tg.tagId
    WHERE uht.user_userId = :userId
    """, nativeQuery = true)
    List<String> findTagsByUserId(@Param("userId") String userId);

}
