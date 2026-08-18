package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.Action;

public interface ActionRepository extends JpaRepository<Action, Integer> {

    boolean existsByUserUserIdAndTargetUserUserIdAndActionType(
            String userId,
            String targetUserId,
            String actionType
    );

}
