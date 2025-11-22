package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.UpdateLocationRequest;
import sit.chat2date.cp25ssi2.services.UserLocationService;

import java.util.Map;

@RestController
@RequestMapping("/location")
@RequiredArgsConstructor
public class LocationController {

    private final UserLocationService userLocationService;

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
