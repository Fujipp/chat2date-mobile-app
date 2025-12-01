package sit.chat2date.cp25ssi2.controllers;

import org.checkerframework.checker.units.qual.A;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    JwtTokenUtil jwtTokenUtil;

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/request-refresh")
    public Map<String, Object> requestRefreshToken(@RequestBody Map<String, String> requestBody) {
        String identifier = requestBody.get("identifier");
        String jwtRefreshToken = jwtTokenUtil.generateRefreshToken(identifier);

        Map<String, Object> response = new HashMap<>();
        response.put("refreshToken", jwtRefreshToken);
        return response;
    }
}
