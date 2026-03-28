package sit.chat2date.cp25ssi2.controllers;

import java.util.HashMap;
import java.util.Map;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.clients.ThSMSClient;
import sit.chat2date.cp25ssi2.dto.*;
import sit.chat2date.cp25ssi2.services.AuthService;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;
import sit.chat2date.cp25ssi2.services.TokenBlacklistService;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    @Autowired
    private final AuthService authService;
    private final ThSMSClient client;
    @Autowired
    private JwtTokenUtil jwtTokenUtil;
    @Autowired
    private TokenBlacklistService tokenBlacklistService;

    @Value("${admin.password}")
    private String adminPassword;

    @PostMapping("/google")
    public ResponseEntity<AuthenticationResponse> authenticateWithGoogle(
            @RequestBody GoogleLoginRequest request
    ) {
        AuthenticationResponse response = authService.verifyGoogleToken(request.getIdToken());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/request-otp")
    public Map<String, Object> send(@RequestBody OtpSendRequest body) {
        String result = client.send(body.getPhoneNumber(), body.getRefCode(), body.getDeviceId());

        // ส่งกลับไปให้ Frontend เพื่อบอกว่า "ส่งรหัสไปที่เบอร์นี้แล้วนะ"
        return Map.of(
                "phoneNumber", body.getPhoneNumber()
        );
    }

    @PostMapping("/verify-otp")
    public Map<String, Object> validate(@RequestBody OtpValidateRequest body) {
        // client.validate จะทำการ: ดึงจาก Redis มาเทียบ -> ถ้าผ่านก็สร้าง JWT/User
        return client.validate(// ส่งไปเฉยๆ ตามโครงสร้างเดิม (หรือส่ง null ก็ได้)
                body.getOtpCode(),
                body.getPhoneNumber(),
                body.isOnLogin()
        );
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

    @PostMapping("/admin-login")
    public Map<String, Object> adminLogin(@RequestBody Map<String, String> requestBody) {
        String identifier = requestBody.get("identifier");
        String password = requestBody.get("password");

        if (password == null || !adminPassword.equals(password)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Incorrect password");
        }

        String jwtToken = jwtTokenUtil.generateToken(identifier);
        String jwtRefreshToken = jwtTokenUtil.generateRefreshToken(identifier);

        Map<String, Object> response = new HashMap<>();
        response.put("token", jwtToken);
        response.put("refreshToken", jwtRefreshToken);
        return response;
    }

    @PostMapping("/logout")
    public ResponseEntity<Map<String, String>> logoutAll(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody LogoutRequest request
    ) {
        try {
            String accessToken = null;
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                accessToken = authHeader.substring(7);
            }

            if (accessToken != null) {
                tokenBlacklistService.blacklistToken(accessToken);
            }

            if (request.getRefreshToken() != null) {
                System.out.println(request.getRefreshToken());

                tokenBlacklistService.blacklistRefreshToken(request.getRefreshToken());

            }

            return ResponseEntity.ok(Map.of(
                    "message", "Logged out from all devices successfully",
                    "status", "success"
            ));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of(
                            "message", "Logout all failed: " + e.getMessage(),
                            "status", "error"
                    ));
        }
    }


}

