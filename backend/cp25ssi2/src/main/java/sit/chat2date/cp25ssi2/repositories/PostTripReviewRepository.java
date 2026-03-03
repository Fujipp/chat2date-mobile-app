package sit.chat2date.cp25ssi2.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import sit.chat2date.cp25ssi2.entities.PostTripReview;

import java.util.List;
import java.util.Optional;

public interface PostTripReviewRepository extends JpaRepository<PostTripReview, Integer> {

    List<PostTripReview> findByAppointment_AppointmentId(Integer appointmentId);

    Optional<PostTripReview> findByAppointment_AppointmentIdAndReviewerId(Integer appointmentId, String reviewerId);

    List<PostTripReview> findByReviewerId(String reviewerId);

    List<PostTripReview> findByTargetUserId(String targetUserId);

    boolean existsByAppointment_AppointmentIdAndReviewerId(Integer appointmentId, String reviewerId);
}
