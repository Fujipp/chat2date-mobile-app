package sit.chat2date.cp25ssi2.controllers;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.dto.PreferenceMatchUserDTO;
import sit.chat2date.cp25ssi2.dto.PreferenceUserDTO;
import sit.chat2date.cp25ssi2.dto.PreferenceUserProfileDTO;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.UserRepository;
import sit.chat2date.cp25ssi2.services.IdentityService;
import sit.chat2date.cp25ssi2.services.SosIncidentService;
import sit.chat2date.cp25ssi2.services.UserService;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private UserService userService;
    @Autowired
    private IdentityService identityService;
    @Autowired
    private SosIncidentService sosIncidentService;

    @GetMapping("")
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @GetMapping("/emergency-calls")
    public ResponseEntity<?> getEmergencyCall(
            @RequestAttribute("userId") String userId) {
        List<String> phoneNumbers = sosIncidentService.getEmergencyContacts(userId);
        return ResponseEntity.ok(Map.of(
                "phoneNumber", phoneNumbers
        ));
    }

    @GetMapping("/{id}")
    public User getUserById(@PathVariable String id) {
        return userRepository.findByUserId(id).orElseThrow(() -> new NotFoundException("User not found"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUserById(@PathVariable String id, @Valid @RequestBody User user) {
        return userService.updateUserById(id, user);
    }

    @PostMapping("")
    public ResponseEntity<User> createUser(@RequestBody User user) {
        User created = userService.createUser(user);
        return ResponseEntity.status(201).body(created);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable String id) {
        return userService.deleteUser(id);
    }

    /**
     * กู้คืนบัญชีที่ถูกลบปลอม (ภายใน 30 วัน)
     */
    @PostMapping("/{id}/restore")
    public ResponseEntity<User> restoreUser(@PathVariable String id) {
        return userService.restoreUser(id);
    }
    /**
     * เช็คสถานะบัญชี (ว่าถูกลบปลอมหรือไม่)
     */
    @GetMapping("/{id}/deletion-status")
    public ResponseEntity<?> checkDeletionStatus(@PathVariable String id) {
        User user = userRepository.findByUserId(id).orElseThrow(() -> new NotFoundException("User not found"));

        if (user.getDeleteFlag()) {
            long daysRemaining = 30 - java.time.Duration
                    .between(user.getDeletedAt(), java.time.LocalDateTime.now())
                    .toDays();

            return ResponseEntity.ok(Map.of(
                    "isDeleted", true,
                    "deletedAt", user.getDeletedAt(),
                    "daysRemaining", daysRemaining > 0 ? daysRemaining : 0,
                    "canRestore", daysRemaining > 0
            ));
        }

        return ResponseEntity.ok(Map.of("isDeleted", false));
    }

    @PostMapping("/preference")
    public ResponseEntity<PreferenceUserDTO> createUserPreference(@RequestHeader("Authorization") String accessToken, @RequestBody PreferenceUserDTO preferenceUser) {
        return userService.createUserPreference(accessToken, preferenceUser);
    }

    @PostMapping("/phone")
    public boolean checkPhone(@RequestBody Map<String, String> requestBody) {
        String phoneNumber = requestBody.get("phoneNumber");
        User user = userRepository.findByPhoneNumber(phoneNumber).orElseThrow(() -> new NotFoundException("User not found"));
        return user != null;
    }

    @PostMapping("/preferenceMatch")
    public ResponseEntity<PreferenceMatchUserDTO> createUserPreferenceMatch(@RequestHeader("Authorization") String accessToken, @RequestBody PreferenceMatchUserDTO preferenceUser) {
        return userService.createUserPreferenceMatch(accessToken, preferenceUser);
    }

    @GetMapping("/{id}/profile")
    public PreferenceUserProfileDTO getUserProfile(@PathVariable String id) {
        return userService.getUserProfile(id);
    }

    @DeleteMapping("/{id}/photo")
    public ResponseEntity<Void> deletePhoto(
            @PathVariable String id,
            @RequestParam List<String> imageUrl
    ) throws IOException {
        identityService.deleteUserPhoto(id, imageUrl);
        return ResponseEntity.noContent().build();
    }


}
