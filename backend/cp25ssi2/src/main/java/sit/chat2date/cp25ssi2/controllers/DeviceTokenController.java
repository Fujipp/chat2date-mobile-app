package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.DeviceTokenRequest;
import sit.chat2date.cp25ssi2.services.DeviceTokenService;

import java.util.Map;

@RestController
@RequestMapping("/device-tokens")
@RequiredArgsConstructor
public class DeviceTokenController {

    private final DeviceTokenService deviceTokenService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody DeviceTokenRequest request) {
        deviceTokenService.registerToken(request);
        return ResponseEntity.status(201).body(Map.of("status", "CREATED"));
    }

    @PostMapping("/remove")
    public ResponseEntity<?> remove(@RequestBody DeviceTokenRequest request) {
        deviceTokenService.removeToken(request);
        return ResponseEntity.ok(Map.of("status", "OK"));
    }

    // class เล็ก ๆ เอาไว้ห่อ response เฉย ๆ
    public record SimpleResponse(String message) { }
}
