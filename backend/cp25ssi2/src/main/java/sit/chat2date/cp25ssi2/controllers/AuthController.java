package sit.chat2date.cp25ssi2.controllers;

import java.util.HashMap;
import java.util.Map;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import sit.chat2date.cp25ssi2.clients.SmsmktClient;
import sit.chat2date.cp25ssi2.dto.*;
import sit.chat2date.cp25ssi2.exceptions.RefreshTokenExpiredException;
import sit.chat2date.cp25ssi2.repositories.UserRepository;
import sit.chat2date.cp25ssi2.services.AuthService;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    @Autowired
    private final AuthService authService;
    private final SmsmktClient client;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    @PostMapping("/google")
    public ResponseEntity<AuthenticationResponse> authenticateWithGoogle(
            @RequestBody GoogleLoginRequest request
    ) {
        AuthenticationResponse response = authService.verifyGoogleToken(request.getIdToken());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/request-otp")
    public Map<String, Object> send(@RequestBody OtpSendRequest body) {
        String token = client.send(body.getPhoneNumber(), body.getRefCode());
        return Map.of("token", token);
    }

    @PostMapping("/verify-otp")
    public Map<String, Object> validate(@RequestBody OtpValidateRequest body) {
        return client.validate(body.getToken(), body.getOtp_code(), body.getRefCode(), body.getPhoneNumber());
    }

    @PostMapping("/request-token")
    public Map<String, Object> requestToken(@RequestBody Map<String, String> requestBody) {
        String identifier = requestBody.get("identifier");
        String jwtToken = jwtTokenUtil.generateToken(identifier);

        Map<String, Object> response = new HashMap<>();
        response.put("token", jwtToken);
        return response;
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<RefreshTokenResponse> refreshToken(@RequestBody RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();
        jwtTokenUtil.validateRefreshToken(refreshToken);

        String subject = jwtTokenUtil.getSubjectFromRefreshToken(refreshToken);
        String newAccessToken = jwtTokenUtil.generateToken(subject);

        return ResponseEntity.ok(new RefreshTokenResponse(newAccessToken));
    }
}

