package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.PreferenceMatch;

public interface PreferenceMatchRepository extends JpaRepository<PreferenceMatch, Integer> {
    PreferenceMatch findPreferenceMatchByUser_UserId(String userUserId);
}
