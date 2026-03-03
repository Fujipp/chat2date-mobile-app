package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.Place;

import java.util.List;

public interface PlaceRepository extends JpaRepository<Place, String> {

    List<Place> findByPlaceNameContainingIgnoreCase(String name);

    boolean existsByPlaceId(String placeId);
}
