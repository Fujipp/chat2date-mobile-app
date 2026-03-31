package sit.chat2date.cp25ssi2.controllers;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.PreferenceMatchUserDTO;
import sit.chat2date.cp25ssi2.dto.PreferenceUserDTO;
import sit.chat2date.cp25ssi2.dto.PreferenceUserProfileDTO;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.services.IdentityService;
import sit.chat2date.cp25ssi2.services.UserService;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * REST controller for user management.
 * Handles CRUD operations, account lifecycle (delete/restore),
 * preferences, and photo management.
 */
@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final IdentityService identityService;

    // ────────────────────────────────────────────────────────────────────────
    // User CRUD
    // ────────────────────────────────────────────────────────────────────────

    /** GET /users — List all users (admin-only). */
    @GetMapping("")
    public List<User> getAllUsers() {
        return userService.getAllUsers();
    }

    /** GET /users/{id} — Get a single user by ID. */
    @GetMapping("/{id}")
    public User getUserById(@PathVariable String id) {
        return userService.getUserById(id);
    }

    /** POST /users — Create a new user. */
    @PostMapping("")
    public ResponseEntity<User> createUser(@RequestBody User user) {
        User created = userService.createUser(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /** PUT /users/{id} — Update an existing user (requires version for optimistic locking). */
    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(
            @PathVariable String id,
            @Valid @RequestBody User user) {
        return userService.updateUserById(id, user);
    }

    /** DELETE /users/{id} — Delete a user (admin = hard delete, user = soft delete). */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable String id) {
        return userService.deleteUser(id);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Account Lifecycle (Soft Delete / Restore)
    // ────────────────────────────────────────────────────────────────────────

    /** POST /users/{id}/restore — Restore a soft-deleted account (within 30 days). */
    @PostMapping("/{id}/restore")
    public ResponseEntity<User> restoreUser(@PathVariable String id) {
        return userService.restoreUser(id);
    }

    /** GET /users/{id}/deletion-status — Check whether an account is soft-deleted and how long until permanent deletion. */
    @GetMapping("/{id}/deletion-status")
    public ResponseEntity<Map<String, Object>> getDeletionStatus(@PathVariable String id) {
        return ResponseEntity.ok(userService.getDeletionStatus(id));
    }

    // ────────────────────────────────────────────────────────────────────────
    // Preferences
    // ────────────────────────────────────────────────────────────────────────

    /** POST /users/preference — Save user preferences (interests, tags, lifestyles, travel styles). */
    @PostMapping("/preference")
    public ResponseEntity<PreferenceUserDTO> savePreference(
            @RequestHeader("Authorization") String accessToken,
            @RequestBody PreferenceUserDTO preferenceUser) {
        return userService.createUserPreference(accessToken, preferenceUser);
    }

    /** POST /users/preferenceMatch — Save match preferences (gender, age range, distance). */
    @PostMapping("/preferenceMatch")
    public ResponseEntity<PreferenceMatchUserDTO> saveMatchPreference(
            @RequestHeader("Authorization") String accessToken,
            @RequestBody PreferenceMatchUserDTO preferenceUser) {
        return userService.createUserPreferenceMatch(accessToken, preferenceUser);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Profile & Phone
    // ────────────────────────────────────────────────────────────────────────

    /** GET /users/{id}/profile — Get full user profile with preferences and photos. */
    @GetMapping("/{id}/profile")
    public PreferenceUserProfileDTO getUserProfile(@PathVariable String id) {
        return userService.getUserProfile(id);
    }

    /** POST /users/phone — Check if a phone number is already registered. */
    @PostMapping("/phone")
    public boolean checkPhoneRegistered(@RequestBody Map<String, String> requestBody) {
        return userService.isPhoneRegistered(requestBody.get("phoneNumber"));
    }

    /** DELETE /users/{id}/photo — Delete user photos by URLs. */
    @DeleteMapping("/{id}/photo")
    public ResponseEntity<Void> deletePhotos(
            @PathVariable String id,
            @RequestParam List<String> imageUrl) throws IOException {
        identityService.deleteUserPhoto(id, imageUrl);
        return ResponseEntity.noContent().build();
    }
}
