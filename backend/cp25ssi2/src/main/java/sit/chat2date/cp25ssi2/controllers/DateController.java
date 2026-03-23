package sit.chat2date.cp25ssi2.controllers;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.UpdateLocationRequest;
import sit.chat2date.cp25ssi2.services.UserLocationService;

import java.util.Map;

@RestController
@RequestMapping("/dates")
@RequiredArgsConstructor
public class DateController {
    private final UserLocationService userLocationService;

    //Real time location
    @PostMapping("/share-location")
    public ResponseEntity<?> shareLocation(
            @RequestHeader(value = "Authorization", required = false) String accessToken,
            @RequestBody UpdateLocationRequest req) {

        String shareLink = userLocationService.updateCurrentUserLocation(accessToken, req);
        return ResponseEntity.ok(Map.of(
                "message", "Location updated successfully",
                "shareUrl", shareLink
        ));
    }
}
