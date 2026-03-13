package sit.chat2date.cp25ssi2.controllers;

import com.fasterxml.jackson.core.JsonProcessingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.ConfirmationRequest;
import sit.chat2date.cp25ssi2.entities.PlaceConfirmation;
import sit.chat2date.cp25ssi2.enums.ConfirmAction;
import sit.chat2date.cp25ssi2.repositories.MatchRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;
import sit.chat2date.cp25ssi2.services.DateRecommendService;

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
    public ConfirmAction GetDateRecommendationConfirmByRoomId(@PathVariable String roomId, @RequestHeader("Authorization") String accessToken) {
        return dateRecommendService.getMyConfirmationStatus(roomId, accessToken);
    }

    @PostMapping("/{roomId}/confirm")
    public PlaceConfirmation ConfirmDateRecommendation(@PathVariable String roomId, @RequestHeader("Authorization") String accessToken, @RequestBody ConfirmationRequest confirmationRequest) {
        return dateRecommendService.confirmPlace(roomId, accessToken, confirmationRequest);
    }
}
