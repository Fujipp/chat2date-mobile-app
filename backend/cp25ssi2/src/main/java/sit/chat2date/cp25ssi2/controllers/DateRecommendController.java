package sit.chat2date.cp25ssi2.controllers;

import com.fasterxml.jackson.core.JsonProcessingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.ConfirmationRequest;
import sit.chat2date.cp25ssi2.dto.SpinStatusResponse;
import sit.chat2date.cp25ssi2.entities.PlaceConfirmation;
import sit.chat2date.cp25ssi2.enums.ConfirmAction;
import sit.chat2date.cp25ssi2.services.DateRecommendService;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/dates/recommendations")
public class DateRecommendController {

    //Date Recommendation

    @Autowired
    private DateRecommendService dateRecommendService;

    @GetMapping("/{roomId}")
    public ResponseEntity<?> GetDateRecommendationByRoomId(@PathVariable String roomId, @RequestParam(required = false, defaultValue = "MIDPOINT") String mode, @RequestParam(required = false) String userTarget, @RequestParam(required = true) int range, @RequestHeader("Authorization") String accessToken, @RequestParam(required = false, defaultValue = "false") boolean forceRefresh) throws JsonProcessingException {
        return dateRecommendService.DateRecommendationById(roomId, mode, userTarget, range, accessToken, forceRefresh);
    }

    @GetMapping("/{roomId}/confirm")
    public ResponseEntity<Map<String, String>> GetDateRecommendationConfirmByRoomId(@PathVariable String roomId, @RequestHeader("Authorization") String accessToken) {
        ConfirmAction action = dateRecommendService.getMyConfirmationStatus(roomId, accessToken);
        Map<String, String> response = new HashMap<>();
        response.put("status", action.name());

        return ResponseEntity.ok(response);
    }

    @PostMapping("/{roomId}/spin")
    public ResponseEntity<Map<String, String>> triggerSpin(
            @PathVariable String roomId) {

        dateRecommendService.triggerSpin(roomId);

        Map<String, String> response = new HashMap<>();
        response.put("message", "Spin command sent successfully");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{roomId}/close-modal")
    public ResponseEntity<Map<String, String>> triggerCloseModal(@PathVariable String roomId, @RequestHeader("Authorization") String accessToken) {
        dateRecommendService.triggerCloseModal(roomId, accessToken);

        Map<String, String> response = new HashMap<>();
        response.put("message", "Close modal command sent successfully");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{roomId}/confirm")
    public PlaceConfirmation ConfirmDateRecommendation(@PathVariable String roomId, @RequestHeader("Authorization") String accessToken, @RequestBody ConfirmationRequest confirmationRequest) {
        return dateRecommendService.confirmPlace(roomId, accessToken, confirmationRequest);
    }

    @GetMapping("/{roomId}/spin-status")
    public ResponseEntity<SpinStatusResponse> getSpinStatus(@PathVariable String roomId) {
        SpinStatusResponse response = dateRecommendService.checkSpinStatus(roomId);

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{roomId}/appointment")
    public ResponseEntity<Void> deleteAppointmentAfterCooldown(
            @PathVariable String roomId,
            @RequestHeader("Authorization") String accessToken) {
        dateRecommendService.deleteAppointmentAfterCooldown(roomId, accessToken);
        return ResponseEntity.noContent().build();
    }
}
