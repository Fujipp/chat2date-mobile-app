package sit.chat2date.cp25ssi2.controllers;


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
import sit.chat2date.cp25ssi2.services.AuthService;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    @Autowired
    private final AuthService authService;

    @PostMapping("/google")
    public ResponseEntity<AuthenticationResponse> authenticateWithGoogle(
            @RequestBody GoogleLoginRequest request
    ) {
        AuthenticationResponse response = authService.verifyGoogleToken(request.getIdToken());
        return ResponseEntity.ok(response);
    }

}
