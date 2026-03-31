package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.DeviceTokenRequest;
import sit.chat2date.cp25ssi2.services.DeviceTokenService;

import java.util.Map;

/**
 * REST controller for FCM device token management.
 * Handles registering and removing push notification tokens.
 */
@RestController
@RequestMapping("/device-tokens")
@RequiredArgsConstructor
public class DeviceTokenController {

    private final DeviceTokenService deviceTokenService;

    /** POST /device-tokens/register — Register a new FCM device token. Returns 201 Created. */
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody DeviceTokenRequest request) {
        deviceTokenService.registerToken(request);
        return ResponseEntity.status(201).body(Map.of("status", "CREATED"));
    }

    /** POST /device-tokens/remove — Remove a registered FCM device token. */
    @PostMapping("/remove")
    public ResponseEntity<?> removeToken(@RequestBody DeviceTokenRequest request) {
        deviceTokenService.removeToken(request);
        return ResponseEntity.ok(Map.of("status", "OK"));
    }
}
