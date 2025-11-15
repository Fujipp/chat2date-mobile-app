package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.Tag;

public interface TagRepository extends JpaRepository<Tag, Integer> {
}
