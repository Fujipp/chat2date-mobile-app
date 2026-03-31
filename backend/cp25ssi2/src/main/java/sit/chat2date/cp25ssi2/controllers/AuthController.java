package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.clients.ThSMSClient;
import sit.chat2date.cp25ssi2.dto.AuthenticationResponse;
import sit.chat2date.cp25ssi2.dto.GoogleLoginRequest;
import sit.chat2date.cp25ssi2.dto.LogoutRequest;
import sit.chat2date.cp25ssi2.dto.OtpSendRequest;
import sit.chat2date.cp25ssi2.dto.OtpValidateRequest;
import sit.chat2date.cp25ssi2.dto.RefreshTokenRequest;
import sit.chat2date.cp25ssi2.dto.RefreshTokenResponse;
import sit.chat2date.cp25ssi2.services.AuthService;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;
import sit.chat2date.cp25ssi2.services.TokenBlacklistService;

import java.util.Map;

/**
 * REST controller for authentication.
 * Handles Google login, OTP, token management, admin login, and logout.
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final ThSMSClient thSMSClient;
    private final JwtTokenUtil jwtTokenUtil;
    private final TokenBlacklistService tokenBlacklistService;

    @Value("${admin.password}")
    private String adminPassword;

    // ────────────────────────────────────────────────────────────────────────
    // Google Authentication
    // ────────────────────────────────────────────────────────────────────────

    /** POST /auth/google — Authenticate with a Google ID token. */
    @PostMapping("/google")
    public ResponseEntity<AuthenticationResponse> loginWithGoogle(@RequestBody GoogleLoginRequest request) {
        return ResponseEntity.ok(authService.verifyGoogleToken(request.getIdToken()));
    }

    // ────────────────────────────────────────────────────────────────────────
    // OTP (Phone Authentication)
    // ────────────────────────────────────────────────────────────────────────

    /** POST /auth/request-otp — Send an OTP code to the given phone number. */
    @PostMapping("/request-otp")
    public Map<String, Object> requestOtp(@RequestBody OtpSendRequest body) {
        thSMSClient.send(body.getPhoneNumber(), body.getRefCode(), body.getDeviceId());
        return Map.of("phoneNumber", body.getPhoneNumber());
    }

    /** POST /auth/verify-otp — Validate an OTP code and return JWT tokens. */
    @PostMapping("/verify-otp")
    public Map<String, Object> verifyOtp(@RequestBody OtpValidateRequest body) {
        return thSMSClient.validate(body.getOtpCode(), body.getPhoneNumber(), body.isOnLogin());
    }

    // ────────────────────────────────────────────────────────────────────────
    // Token Management
    // ────────────────────────────────────────────────────────────────────────

    /** POST /auth/request-token — Generate an access token for a given identifier. */
    @PostMapping("/request-token")
    public Map<String, Object> requestAccessToken(@RequestBody Map<String, String> requestBody) {
        String token = jwtTokenUtil.generateToken(requestBody.get("identifier"));
        return Map.of("token", token);
    }

    /** POST /auth/refresh-token — Exchange a valid refresh token for a new access token. */
    @PostMapping("/refresh-token")
    public ResponseEntity<RefreshTokenResponse> refreshAccessToken(@RequestBody RefreshTokenRequest request) {
        jwtTokenUtil.validateRefreshToken(request.getRefreshToken());

        String subject = jwtTokenUtil.getSubjectFromRefreshToken(request.getRefreshToken());
        String newAccessToken = jwtTokenUtil.generateToken(subject);

        return ResponseEntity.ok(new RefreshTokenResponse(newAccessToken));
    }

    // ────────────────────────────────────────────────────────────────────────
    // Admin Login
    // ────────────────────────────────────────────────────────────────────────

    /** POST /auth/admin-login — Authenticate admin with identifier + password, return access + refresh tokens. */
    @PostMapping("/admin-login")
    public Map<String, Object> loginAsAdmin(@RequestBody Map<String, String> requestBody) {
        String identifier = requestBody.get("identifier");
        String password = requestBody.get("password");

        if (password == null || !adminPassword.equals(password)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Incorrect password");
        }

        return Map.of(
                "token", jwtTokenUtil.generateToken(identifier),
                "refreshToken", jwtTokenUtil.generateRefreshToken(identifier)
        );
    }

    // ────────────────────────────────────────────────────────────────────────
    // Logout
    // ────────────────────────────────────────────────────────────────────────

    /** POST /auth/logout — Blacklist access and refresh tokens to log out from all devices. */
    @PostMapping("/logout")
    public ResponseEntity<Map<String, String>> logout(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody LogoutRequest request) {
        try {
            String accessToken = extractBearerToken(authHeader);

            if (accessToken != null) {
                tokenBlacklistService.blacklistToken(accessToken);
            }
            if (request.getRefreshToken() != null) {
                tokenBlacklistService.blacklistRefreshToken(request.getRefreshToken());
            }

            return ResponseEntity.ok(Map.of("message", "Logged out successfully", "status", "success"));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("message", "Logout failed: " + e.getMessage(), "status", "error"));
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // Helpers
    // ────────────────────────────────────────────────────────────────────────

    private String extractBearerToken(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        return null;
    }
}
