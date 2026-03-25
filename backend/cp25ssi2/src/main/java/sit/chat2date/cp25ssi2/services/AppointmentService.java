package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import sit.chat2date.cp25ssi2.dto.AppointmentListResponse;
import sit.chat2date.cp25ssi2.dto.AppointmentRequest;
import sit.chat2date.cp25ssi2.dto.AppointmentResponse;
import sit.chat2date.cp25ssi2.dto.AppointmentUpdateRequest;
import sit.chat2date.cp25ssi2.entities.Appointment;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.Place;
import sit.chat2date.cp25ssi2.enums.AppointmentStatus;
import sit.chat2date.cp25ssi2.exceptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceptions.ConflictException;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.AppointmentRepository;
import sit.chat2date.cp25ssi2.repositories.MatchRepository;
import sit.chat2date.cp25ssi2.repositories.PlaceRepository;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AppointmentService {

    private final AppointmentRepository appointmentRepository;
    private final MatchRepository matchRepository;
    private final PlaceRepository placeRepository;
    private final ChatSocketService chatSocketService;

    // ────────────────────────────────────────────────────────────────────────────
    // POST /dates/appointments → 201 Created
    // ────────────────────────────────────────────────────────────────────────────

    /**
     * Create a new appointment for a chat room.
     * - Verifies the calling user is a member of the given room.
     * - Upserts the Place record (from Hat data in the request).
     * - Rejects with 409 if there is already an active (PLACE_SELECTED or
     * SCHEDULED) appointment.
     */
    @Transactional
    public AppointmentResponse createAppointment(String userId, AppointmentRequest request) {

        // 1. Validate dateTime is not in the past
        if (request.getDateTime() != null && request.getDateTime().isBefore(LocalDateTime.now())) {
            throw new BadRequestException("dateTime must be a future date/time");
        }

        // 2. Find match (room) and verify membership
        Match match = matchRepository.findById(request.getRoomId())
                .orElseThrow(() -> new NotFoundException("Room not found"));

        assertRoomMember(userId, match);

        // 3. Check for existing active appointment → 409 CONFLICT
        List<AppointmentStatus> activeStatuses = List.of(
                AppointmentStatus.PLACE_SELECTED,
                AppointmentStatus.SCHEDULED);

        if (appointmentRepository.existsByMatch_IdAndStatusIn(request.getRoomId(), activeStatuses)) {
            throw new ConflictException("An active appointment already exists for this room");
        }

        // 4. Upsert Place (placeId/placeName come from Hat side)
        Place place = placeRepository.findById(request.getPlaceId())
                .orElseGet(() -> Place.builder()
                        .placeId(request.getPlaceId())
                        .placeName(request.getPlaceName())
                        // latitude / longitude are required by DB; default 0 when not provided
                        .latitude(java.math.BigDecimal.ZERO)
                        .longitude(java.math.BigDecimal.ZERO)
                        .build());

        // Always keep placeName up-to-date
        place.setPlaceName(request.getPlaceName());
        place = placeRepository.save(place);

        // 5. Save appointment
        Appointment appointment = Appointment.builder()
                .match(match)
                .place(place)
                .dateTime(request.getDateTime())
                .status(request.getDateTime() != null
                        ? AppointmentStatus.SCHEDULED
                        : AppointmentStatus.PLACE_SELECTED)
                .build();

        appointment = appointmentRepository.save(appointment);
        broadcastAppointmentChange("CREATED", userId, appointment);
        return toResponse(appointment);
    }

    // ────────────────────────────────────────────────────────────────────────────
    // GET /dates/appointments/{roomId} → 200 OK
    // ────────────────────────────────────────────────────────────────────────────

    /**
     * Return all appointments for the given room.
     * - Verifies the calling user is a member of the room.
     */
    @Transactional(readOnly = true)
    public AppointmentListResponse getAppointmentsByRoomId(String userId, Integer roomId) {

        Match match = matchRepository.findById(roomId)
                .orElseThrow(() -> new NotFoundException("Room not found"));

        assertRoomMember(userId, match);

        List<AppointmentResponse> list = appointmentRepository.findByMatch_Id(roomId)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());

        return AppointmentListResponse.builder().appointments(list).build();
    }

    // ────────────────────────────────────────────────────────────────────────────
    // PUT /dates/appointments/{appointmentId} → 200 OK
    // ────────────────────────────────────────────────────────────────────────────

    /**
     * Update the dateTime of an existing appointment.
     * - Verifies the calling user is a member of the room.
     * - Rejects with 400 if dateTime is in the past.
     * - Rejects with 409 if updating would conflict (same room, another active
     * appointment).
     */
    @Transactional
    public AppointmentResponse updateAppointment(String userId, Integer appointmentId,
            AppointmentUpdateRequest request) {

        // 1. Validate dateTime
        if (request.getDateTime() != null && request.getDateTime().isBefore(LocalDateTime.now())) {
            throw new BadRequestException("dateTime must be a future date/time");
        }

        // 2. Find appointment
        Appointment appointment = appointmentRepository.findByIdWithMatch(appointmentId)
                .orElseThrow(() -> new NotFoundException("Appointment not found"));

        // 3. Verify room membership
        assertRoomMember(userId, appointment.getMatch());

        // 4. Check for conflict: another SCHEDULED appointment in same room
        List<Appointment> activeInRoom = appointmentRepository
                .findByMatch_IdAndStatus(appointment.getMatch().getId(), AppointmentStatus.SCHEDULED);

        boolean anotherConflict = activeInRoom.stream()
                .anyMatch(a -> !a.getAppointmentId().equals(appointmentId));

        if (anotherConflict) {
            throw new ConflictException("Another scheduled appointment already exists for this room");
        }

        // 5. Apply update
        appointment.setDateTime(request.getDateTime());
        appointment.setStatus(AppointmentStatus.SCHEDULED);
        appointment = appointmentRepository.save(appointment);

        broadcastAppointmentChange("UPDATED", userId, appointment);

        return toResponse(appointment);
    }

    // ────────────────────────────────────────────────────────────────────────────
    // DELETE /dates/appointments/{appointmentId} → 200 OK
    // ────────────────────────────────────────────────────────────────────────────

    /**
     * Soft-cancel an appointment.
     * - Verifies the calling user is a member of the room.
     * - Keeps the row in DB and only updates the status to CANCELLED.
     */
    @Transactional
    public AppointmentResponse deleteAppointment(String userId, Integer appointmentId) {

        Appointment appointment = appointmentRepository.findByIdWithMatch(appointmentId)
                .orElseThrow(() -> new NotFoundException("Appointment not found"));

        assertRoomMember(userId, appointment.getMatch());

        if (appointment.getStatus() != AppointmentStatus.CANCELLED) {
            appointment.setStatus(AppointmentStatus.CANCELLED);
            appointment.setIsNotified(false);
            appointment = appointmentRepository.save(appointment);

            broadcastAppointmentChange("CANCELLED", userId, appointment);
        }

        return toResponse(appointment);
    }

    // ────────────────────────────────────────────────────────────────────────────
    // Helpers
    // ────────────────────────────────────────────────────────────────────────────

    /** Throw 403 if userId is not userId1 or userId2 of the match. */
    private void assertRoomMember(String userId, Match match) {
        boolean isMember = match.getUserId1().getUserId().equals(userId)
                || match.getUserId2().getUserId().equals(userId);
        if (!isMember) {
            throw new ForbiddenAccessException("You are not a member of this room");
        }
    }

    private AppointmentResponse toResponse(Appointment a) {
        return AppointmentResponse.builder()
                .appointmentId(a.getAppointmentId())
                .roomId(a.getMatch().getId())
                .placeId(a.getPlace().getPlaceId())
                .placeName(a.getPlace().getPlaceName())
                .dateTime(a.getDateTime())
                .status(a.getStatus())
                .createdAt(a.getCreatedAt())
                .updatedAt(a.getUpdatedAt())
                .build();
    }

    private void broadcastAppointmentChange(String action, String actorUserId, Appointment appointment) {
        Runnable broadcaster = () -> {
            try {
                Map<String, Object> payload = new HashMap<>();
                payload.put("type", "APPOINTMENT_CHANGE");
                payload.put("action", action);
                payload.put("actorUserId", actorUserId);
                payload.put("roomId", appointment.getMatch().getId());
                payload.put("appointmentId", appointment.getAppointmentId());
                payload.put("status", appointment.getStatus() != null ? appointment.getStatus().name() : null);
                payload.put("updatedAt", appointment.getUpdatedAt());
                chatSocketService.broadcastAppointmentChange(String.valueOf(appointment.getMatch().getId()), payload);
            } catch (Exception e) {
                System.out.println("[AppointmentSocket] Failed to broadcast appointment change: " + e.getMessage());
            }
        };

        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    broadcaster.run();
                }
            });
        } else {
            broadcaster.run();
        }
    }
}
