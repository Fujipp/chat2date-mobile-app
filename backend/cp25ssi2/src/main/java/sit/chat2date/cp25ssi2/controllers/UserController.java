package sit.chat2date.cp25ssi2.controllers;

import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.dto.PreferenceMatchUserDto;
import sit.chat2date.cp25ssi2.dto.PreferenceUserDto;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.PreferenceMatchRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;
import sit.chat2date.cp25ssi2.services.UserService;

import java.util.List;
import java.util.Map;

@RestController
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserService userService;

    @GetMapping("/users")
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @GetMapping("/users/{id}")
    public User getUserById(@PathVariable String id) {
        return userRepository.findByUserId(id).orElseThrow(() -> new NotFoundException("User not found"));
    }

    @PutMapping("/users/{id}")
    public ResponseEntity<User> updateUserById(@PathVariable String id, @Valid @RequestBody User user) {
        return userService.updateUserById(id, user);
    }

    @PostMapping("/users")
    public User createUser(@RequestBody User user) {
        return userService.createUser(user);
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable String id) {
        return userService.deleteUser(id);
    }

    @GetMapping("/users/{id}/preference")
    public ResponseEntity<PreferenceUserDto> UserPreferenceById(@PathVariable String id) {
        return userService.UserPreferenceById(id);
    }

    @PostMapping("/users/preference")
    public ResponseEntity<PreferenceUserDto> createUserPreference(@RequestHeader("Authorization") String accessToken, @RequestBody PreferenceUserDto preferenceUser) {
        return userService.createUserPreference(accessToken, preferenceUser);
    }

    @PostMapping("/users/phone")
    public boolean checkPhone(@RequestBody Map<String, String> requestBody) {
        String phoneNumber = requestBody.get("phoneNumber");
        User user = userRepository.findByPhoneNumber(phoneNumber).orElseThrow(() -> new NotFoundException("User not found"));
        return user != null;
    }

    @PostMapping("/users/preferenceMatch")
    public ResponseEntity<PreferenceMatchUserDto> createUserPreferenceMatch(@RequestHeader("Authorization") String accessToken, @RequestBody PreferenceMatchUserDto preferenceUser) {
        return userService.createUserPreferenceMatch(accessToken, preferenceUser);
    }

}