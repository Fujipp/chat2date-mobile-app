package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.dto.PostTripReviewRequest;
import sit.chat2date.cp25ssi2.entities.Appointment;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.PostTripReview;
import sit.chat2date.cp25ssi2.entities.RelationshipStats;
import sit.chat2date.cp25ssi2.repositories.AppointmentRepository;
import sit.chat2date.cp25ssi2.repositories.PostTripReviewRepository;
import sit.chat2date.cp25ssi2.repositories.RelationshipStatsRepository;

@Service
@RequiredArgsConstructor
public class PostTripReviewService {

    private final AppointmentRepository appointmentRepository;
    private final PostTripReviewRepository postTripReviewRepository;
    private final RelationshipStatsRepository relationshipStatsRepository;

    public boolean checkReviewStatus(String userId, Integer appointmentId) {
        if (!appointmentRepository.existsById(appointmentId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "ไม่พบนัดหมาย (404)");
        }
        return postTripReviewRepository.existsByAppointment_AppointmentIdAndReviewerId(appointmentId, userId);
    }

    @Transactional
    public void submitReview(String userId, Integer appointmentId, PostTripReviewRequest req) {
        if (req.getPartnerId() == null || req.getIsSatisfied() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "ส่งฟิลด์มาไม่ครบ (400)");
        }

        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ไม่พบนัดหมาย (404)"));

        Match match = appointment.getMatch();
        String u1Id = match.getUserId1().getUserId();
        String u2Id = match.getUserId2().getUserId();

        if (!userId.equals(u1Id) && !userId.equals(u2Id)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "คุณไม่ได้อยู่ในนัดหมายนี้");
        }

        String actualPartnerId = userId.equals(u1Id) ? u2Id : u1Id;
        if (!actualPartnerId.equals(req.getPartnerId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "ประเมินคนที่ไม่ใช่คู่เดทของตัวเอง (403)");
        }

        if (postTripReviewRepository.existsByAppointment_AppointmentIdAndReviewerId(appointmentId, userId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "ส่งประเมินซ้ำสำหรับนัดหมายนี้ไปแล้ว (409)");
        }

        PostTripReview review = new PostTripReview();
        review.setAppointment(appointment);
        review.setReviewerId(userId);
        review.setTargetUserId(actualPartnerId);
        review.setIsSatisfied(req.getIsSatisfied());
        review.setWantToContinue(req.getWantToContinue());
        review.setWantToUnmatch(req.getWantToUnmatch());

        postTripReviewRepository.save(review);

        if (req.getIsSatisfied()) {
            RelationshipStats stats = relationshipStatsRepository.findById(match.getId())
                    .orElse(null);
            if (stats != null) {
                stats.setScore(stats.getScore() + 20);
                relationshipStatsRepository.save(stats);
            }
        }

    }
}