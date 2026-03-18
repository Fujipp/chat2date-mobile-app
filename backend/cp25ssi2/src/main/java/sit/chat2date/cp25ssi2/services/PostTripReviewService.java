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
import sit.chat2date.cp25ssi2.repositories.MatchRepository;
import sit.chat2date.cp25ssi2.repositories.PostTripReviewRepository;
import sit.chat2date.cp25ssi2.repositories.RelationshipStatsRepository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PostTripReviewService {

    private final AppointmentRepository appointmentRepository;
    private final PostTripReviewRepository postTripReviewRepository;
    private final RelationshipStatsRepository relationshipStatsRepository;
    private final ChatSocketService chatSocketService;
    private final MatchRepository matchRepository;

    public boolean checkReviewStatus(String userId, Integer appointmentId) {
        if (!appointmentRepository.existsById(appointmentId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "ไม่พบนัดหมาย (404)");
        }
        return postTripReviewRepository
                .existsByAppointment_AppointmentIdAndReviewerId(appointmentId, userId);
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
        String roomId = match.getId().toString(); // roomId = matchId

        if (!userId.equals(u1Id) && !userId.equals(u2Id)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "คุณไม่ได้อยู่ในนัดหมายนี้");
        }

        String actualPartnerId = userId.equals(u1Id) ? u2Id : u1Id;
        if (!actualPartnerId.equals(req.getPartnerId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "ประเมินคนที่ไม่ใช่คู่เดทของตัวเอง (403)");
        }

//        if (postTripReviewRepository.existsByAppointment_AppointmentIdAndReviewerId(appointmentId, userId)) {
//            throw new ResponseStatusException(HttpStatus.CONFLICT, "ส่งประเมินซ้ำสำหรับนัดหมายนี้ไปแล้ว (409)");
//        }

        PostTripReview existing = postTripReviewRepository
                .findByAppointment_AppointmentIdAndReviewerId(appointmentId, userId)
                .orElse(null);

        if (existing != null) {
            if (req.getWantToContinue() != null) existing.setWantToContinue(req.getWantToContinue());
            if (req.getWantToUnmatch() != null) existing.setWantToUnmatch(req.getWantToUnmatch());
            postTripReviewRepository.save(existing);
        } else {
            PostTripReview review = new PostTripReview();
            review.setAppointment(appointment);
            review.setReviewerId(userId);
            review.setTargetUserId(actualPartnerId);
            review.setIsSatisfied(req.getIsSatisfied());
            review.setWantToContinue(req.getWantToContinue());
            review.setWantToUnmatch(req.getWantToUnmatch());
            postTripReviewRepository.save(review);
        }

        List<PostTripReview> allReviews = postTripReviewRepository.findByAppointment_AppointmentId(appointmentId);
        boolean bothSubmitted = allReviews.size() >= 2;
        if (!bothSubmitted) {
            Map<String, Object> waitingPayload = new HashMap<>();
            waitingPayload.put("type", "REVIEW_WAITING");
            chatSocketService.notifyUser(userId, waitingPayload);
            return;
        }

        PostTripReview reviewA = allReviews.stream().filter(r -> r.getReviewerId().equals(u1Id)).findFirst().orElse(null);
        PostTripReview reviewB = allReviews.stream().filter(r -> r.getReviewerId().equals(u2Id)).findFirst().orElse(null);
        if (reviewA == null || reviewB == null) return;

        boolean aSatisfied = Boolean.TRUE.equals(reviewA.getIsSatisfied());
        boolean bSatisfied = Boolean.TRUE.equals(reviewB.getIsSatisfied());
        Map<String, Object> resultPayload = new HashMap<>();
        resultPayload.put("type", "REVIEW_RESULT");

        if (aSatisfied && bSatisfied) {
            resultPayload.put("outcome", "BOTH_SATISFIED");
            RelationshipStats stats = relationshipStatsRepository.findById(match.getId()).orElse(null);
            if (stats != null) {
                stats.setScore(stats.getScore() + 20);
                relationshipStatsRepository.save(stats);
            }
            chatSocketService.broadcastReviewResult(roomId, resultPayload);
            return;
        }

        boolean isOneSided = aSatisfied != bSatisfied;
        if (isOneSided) {
            if (reviewA.getWantToContinue() == null || reviewB.getWantToContinue() == null) {
                if (reviewA.getWantToContinue() == null && reviewB.getWantToContinue() == null) {
                    resultPayload.put("outcome", "ONE_SIDED");
                    chatSocketService.broadcastReviewResult(roomId, resultPayload);
                } else {
                    Map<String, Object> waitingPayload = new HashMap<>();
                    waitingPayload.put("type", "REVIEW_WAITING");
                    chatSocketService.notifyUser(userId, waitingPayload);
                }
                return;
            }

            boolean aContinue = Boolean.TRUE.equals(reviewA.getWantToContinue());
            boolean bContinue = Boolean.TRUE.equals(reviewB.getWantToContinue());

            if (aContinue && bContinue) {
                resultPayload.put("outcome", "CONTINUE");
                RelationshipStats stats = relationshipStatsRepository.findById(match.getId()).orElse(null);
                if (stats != null) {
                    stats.setScore(stats.getScore() + 20);
                    relationshipStatsRepository.save(stats);
                }
                chatSocketService.broadcastReviewResult(roomId, resultPayload);
                return;
            }
        }

        boolean aUnmatch = Boolean.TRUE.equals(reviewA.getWantToUnmatch());
        boolean bUnmatch = Boolean.TRUE.equals(reviewB.getWantToUnmatch());

        if (aUnmatch || bUnmatch) {
            resultPayload.put("outcome", "UNMATCH");
            chatSocketService.broadcastReviewResult(roomId, resultPayload);

            Match findMatch = matchRepository.findById(match.getId()).orElse(null);
            if (findMatch != null) {
                findMatch.setDeleteFlag(true);
                matchRepository.save(findMatch);
            }
            return;
        }

        if (reviewA.getWantToUnmatch() == null || reviewB.getWantToUnmatch() == null) {
            if (reviewA.getWantToUnmatch() == null && reviewB.getWantToUnmatch() == null) {
                resultPayload.put("outcome", "BOTH_UNSATISFIED");
                chatSocketService.broadcastReviewResult(roomId, resultPayload);
            } else {
                Map<String, Object> waitingPayload = new HashMap<>();
                waitingPayload.put("type", "REVIEW_WAITING");
                chatSocketService.notifyUser(userId, waitingPayload);
            }
            return;
        }

        resultPayload.put("outcome", "CONTINUE");
        RelationshipStats stats = relationshipStatsRepository.findById(match.getId()).orElse(null);
        if (stats != null) {
            stats.setScore(stats.getScore() + 20);
            relationshipStatsRepository.save(stats);
        }
        chatSocketService.broadcastReviewResult(roomId, resultPayload);
    }
}