package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.UpdateLocationRequest;
import sit.chat2date.cp25ssi2.services.UserLocationService;

import java.util.Map;

/**
 * REST controller for user location updates.
 * Used for real-time location tracking during dates.
 */
@RestController
@RequestMapping("/location")
@RequiredArgsConstructor
public class LocationController {

    private final UserLocationService userLocationService;

    /** POST /location/update — Update the current user's GPS location. */
    @PostMapping("/update")
    public ResponseEntity<Map<String, Object>> updateLocation(
            @RequestHeader("Authorization") String accessToken,
            @RequestBody UpdateLocationRequest body
    ) {
        userLocationService.updateCurrentUserLocation(accessToken, body);

        return ResponseEntity.ok(Map.of(
                "status", "ok"
        ));
    }
}
