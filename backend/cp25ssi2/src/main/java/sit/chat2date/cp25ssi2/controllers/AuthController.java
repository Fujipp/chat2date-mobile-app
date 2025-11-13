package sit.chat2date.cp25ssi2.controllers;


import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import sit.chat2date.cp25ssi2.clients.SmsmktClient;
import sit.chat2date.cp25ssi2.dto.AuthenticationResponse;
import sit.chat2date.cp25ssi2.dto.GoogleLoginRequest;
import sit.chat2date.cp25ssi2.dto.OtpSendRequest;
import sit.chat2date.cp25ssi2.dto.OtpValidateRequest;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.Provider;
import sit.chat2date.cp25ssi2.enums.Sex;
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
        String token = client.send(body.getPhone(), body.getRefCode());
        return Map.of("token", token);
    }

    @PostMapping("/verify-otp")
    public Map<String, Object> validate(@RequestBody OtpValidateRequest body) {
        Map<String, Object> ok = client.validate(body.getToken(), body.getOtp_code(), body.getRefCode(), body.getPhoneNumber());
        return Map.of("valid", ok);
    }

    @PostMapping("/request-token")
    public Map<String, Object> requestToken(@RequestBody Map<String, String> requestBody) {
        String identifier = requestBody.get("identifier");
        String jwtToken = jwtTokenUtil.generateToken(identifier);

        Map<String, Object> response = new HashMap<>();
        response.put("token", jwtToken);
        return response;
    }
    //refresh
    @PostMapping("/refresh-token")
    public Map<String, Object> validate(@RequestBody String accessToken) {
        jwtTokenUtil.generateRefreshToken(accessToken);
        return Map.of("refresh-token", jwtTokenUtil.generateRefreshToken(accessToken));
    }

}
