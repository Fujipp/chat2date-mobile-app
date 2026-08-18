package sit.chat2date.cp25ssi2.controllers;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.AppointmentListResponse;
import sit.chat2date.cp25ssi2.dto.AppointmentRequest;
import sit.chat2date.cp25ssi2.dto.AppointmentResponse;
import sit.chat2date.cp25ssi2.dto.AppointmentUpdateRequest;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.UnauthorizedAccessException;
import sit.chat2date.cp25ssi2.services.AppointmentService;

import java.util.Optional;

/**
 * REST controller for date appointments.
 * Manages creating, reading, updating, and cancelling appointments between matched users.
 */
@RestController
@RequestMapping("/dates/appointments")
@RequiredArgsConstructor
public class AppointmentController {

    private final AppointmentService appointmentService;

    // ────────────────────────────────────────────────────────────────────────
    // CRUD
    // ────────────────────────────────────────────────────────────────────────

    /** POST /dates/appointments — Create a new appointment for a chat room. Returns 201 Created. */
    @PostMapping
    public ResponseEntity<AppointmentResponse> createAppointment(
            @AuthenticationPrincipal Optional<User> userOpt,
            @Valid @RequestBody AppointmentRequest request) {

        User user = getAuthenticatedUser(userOpt);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(appointmentService.createAppointment(user.getUserId(), request));
    }

    /** GET /dates/appointments/{roomId} — List all appointments for a room. */
    @GetMapping("/{roomId}")
    public ResponseEntity<AppointmentListResponse> getAppointmentsByRoom(
            @AuthenticationPrincipal Optional<User> userOpt,
            @PathVariable Integer roomId) {

        User user = getAuthenticatedUser(userOpt);
        return ResponseEntity.ok(appointmentService.getAppointmentsByRoomId(user.getUserId(), roomId));
    }

    /** PUT /dates/appointments/{appointmentId} — Update the date/time of an existing appointment. */
    @PutMapping("/{appointmentId}")
    public ResponseEntity<AppointmentResponse> updateAppointment(
            @AuthenticationPrincipal Optional<User> userOpt,
            @PathVariable Integer appointmentId,
            @Valid @RequestBody AppointmentUpdateRequest request) {

        User user = getAuthenticatedUser(userOpt);
        return ResponseEntity.ok(appointmentService.updateAppointment(user.getUserId(), appointmentId, request));
    }

    /** DELETE /dates/appointments/{appointmentId} — Cancel (soft-delete) an appointment. */
    @DeleteMapping("/{appointmentId}")
    public ResponseEntity<AppointmentResponse> cancelAppointment(
            @AuthenticationPrincipal Optional<User> userOpt,
            @PathVariable Integer appointmentId) {

        User user = getAuthenticatedUser(userOpt);
        return ResponseEntity.ok(appointmentService.deleteAppointment(user.getUserId(), appointmentId));
    }

    // ────────────────────────────────────────────────────────────────────────
    // Helpers
    // ────────────────────────────────────────────────────────────────────────

    private User getAuthenticatedUser(Optional<User> userOpt) {
        return userOpt.orElseThrow(() -> new UnauthorizedAccessException("User not found"));
    }
}
