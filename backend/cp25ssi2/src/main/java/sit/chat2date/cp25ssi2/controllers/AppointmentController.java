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
import sit.chat2date.cp25ssi2.services.AppointmentService;

import java.util.Optional;

@RestController
@RequestMapping("/dates/appointments")
@RequiredArgsConstructor
public class AppointmentController {

    private final AppointmentService appointmentService;

    /**
     * POST /api/v1/dates/appointments
     * Header: accessToken (JWT)
     * Body: { roomId, placeId, placeName, dateTime }
     * Response: 201 Created
     */
    @PostMapping
    public ResponseEntity<AppointmentResponse> createAppointment(
            @AuthenticationPrincipal Optional<User> userOpt,
            @Valid @RequestBody AppointmentRequest request) {

        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        AppointmentResponse response = appointmentService.createAppointment(user.getUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * GET /api/v1/dates/appointments/{roomId}
     * Header: accessToken (JWT)
     * Response: 200 OK — list of appointments for the room
     */
    @GetMapping("/{roomId}")
    public ResponseEntity<AppointmentListResponse> getAppointmentsByRoomId(
            @AuthenticationPrincipal Optional<User> userOpt,
            @PathVariable Integer roomId) {

        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        AppointmentListResponse response = appointmentService.getAppointmentsByRoomId(user.getUserId(), roomId);
        return ResponseEntity.ok(response);
    }

    /**
     * PUT /api/v1/dates/appointments/{appointmentId}
     * Header: accessToken (JWT)
     * Body: { dateTime }
     * Response: 200 OK
     */
    @PutMapping("/{appointmentId}")
    public ResponseEntity<AppointmentResponse> updateAppointment(
            @AuthenticationPrincipal Optional<User> userOpt,
            @PathVariable Integer appointmentId,
            @Valid @RequestBody AppointmentUpdateRequest request) {

        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        AppointmentResponse response = appointmentService.updateAppointment(user.getUserId(), appointmentId, request);
        return ResponseEntity.ok(response);
    }

    /**
     * DELETE /api/v1/dates/appointments/{appointmentId}
     * Header: accessToken (JWT)
     * Response: 200 OK
     */
    @DeleteMapping("/{appointmentId}")
    public ResponseEntity<AppointmentResponse> deleteAppointment(
            @AuthenticationPrincipal Optional<User> userOpt,
            @PathVariable Integer appointmentId) {

        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        AppointmentResponse response = appointmentService.deleteAppointment(user.getUserId(), appointmentId);
        return ResponseEntity.ok(response);
    }
}
