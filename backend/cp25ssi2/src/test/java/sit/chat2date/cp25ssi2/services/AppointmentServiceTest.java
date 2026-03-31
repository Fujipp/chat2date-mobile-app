package sit.chat2date.cp25ssi2.services;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import sit.chat2date.cp25ssi2.dto.AppointmentListResponse;
import sit.chat2date.cp25ssi2.dto.AppointmentRequest;
import sit.chat2date.cp25ssi2.dto.AppointmentResponse;
import sit.chat2date.cp25ssi2.dto.AppointmentUpdateRequest;
import sit.chat2date.cp25ssi2.entities.Appointment;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.Place;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.AppointmentStatus;
import sit.chat2date.cp25ssi2.exceptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceptions.ConflictException;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.AppointmentRepository;
import sit.chat2date.cp25ssi2.repositories.MatchRepository;
import sit.chat2date.cp25ssi2.repositories.PlaceRepository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AppointmentServiceTest {

    @Mock
    private AppointmentRepository appointmentRepository;
    @Mock
    private MatchRepository matchRepository;
    @Mock
    private PlaceRepository placeRepository;
    @Mock
    private ChatSocketService chatSocketService;

    @InjectMocks
    private AppointmentService appointmentService;

    private User user1;
    private User user2;
    private Match match;
    private Place place;
    private Appointment appointment;

    @BeforeEach
    void setUp() {
        user1 = new User();
        user1.setUserId("user-001");

        user2 = new User();
        user2.setUserId("user-002");

        match = new Match();
        match.setId(1);
        match.setUserId1(user1);
        match.setUserId2(user2);

        place = Place.builder()
                .placeId("place-001")
                .placeName("Central World")
                .latitude(BigDecimal.ZERO)
                .longitude(BigDecimal.ZERO)
                .build();

        appointment = Appointment.builder()
                .appointmentId(100)
                .match(match)
                .place(place)
                .dateTime(LocalDateTime.now().plusDays(3))
                .status(AppointmentStatus.SCHEDULED)
                .build();
    }

    // ────────────────────────────────────────────────────────────────────────
    // createAppointment
    // ────────────────────────────────────────────────────────────────────────

    @Nested
    @DisplayName("createAppointment")
    class CreateAppointmentTests {

        @Test
        @DisplayName("should create appointment successfully")
        void createAppointment_success() {
            AppointmentRequest request = new AppointmentRequest();
            request.setRoomId(1);
            request.setPlaceId("place-001");
            request.setPlaceName("Central World");
            request.setDateTime(LocalDateTime.now().plusDays(3));

            when(matchRepository.findById(1)).thenReturn(Optional.of(match));
            when(appointmentRepository.existsByMatch_IdAndStatusIn(eq(1), anyList())).thenReturn(false);
            when(placeRepository.findById("place-001")).thenReturn(Optional.of(place));
            when(placeRepository.save(any(Place.class))).thenReturn(place);
            when(appointmentRepository.save(any(Appointment.class))).thenReturn(appointment);

            AppointmentResponse result = appointmentService.createAppointment("user-001", request);

            assertNotNull(result);
            assertEquals(100, result.getAppointmentId());
            verify(appointmentRepository).save(any(Appointment.class));
        }

        @Test
        @DisplayName("should throw BadRequestException when dateTime is in the past")
        void createAppointment_pastDateTime() {
            AppointmentRequest request = new AppointmentRequest();
            request.setRoomId(1);
            request.setPlaceId("place-001");
            request.setPlaceName("Central World");
            request.setDateTime(LocalDateTime.now().minusDays(1));

            assertThrows(BadRequestException.class,
                    () -> appointmentService.createAppointment("user-001", request));
        }

        @Test
        @DisplayName("should throw NotFoundException when room not found")
        void createAppointment_roomNotFound() {
            AppointmentRequest request = new AppointmentRequest();
            request.setRoomId(999);
            request.setPlaceId("place-001");
            request.setPlaceName("Central World");
            request.setDateTime(LocalDateTime.now().plusDays(1));

            when(matchRepository.findById(999)).thenReturn(Optional.empty());

            assertThrows(NotFoundException.class,
                    () -> appointmentService.createAppointment("user-001", request));
        }

        @Test
        @DisplayName("should throw ForbiddenAccessException when user is not a room member")
        void createAppointment_notRoomMember() {
            AppointmentRequest request = new AppointmentRequest();
            request.setRoomId(1);
            request.setPlaceId("place-001");
            request.setPlaceName("Central World");
            request.setDateTime(LocalDateTime.now().plusDays(1));

            when(matchRepository.findById(1)).thenReturn(Optional.of(match));

            assertThrows(ForbiddenAccessException.class,
                    () -> appointmentService.createAppointment("user-999", request));
        }

        @Test
        @DisplayName("should throw ConflictException when active appointment already exists")
        void createAppointment_conflict() {
            AppointmentRequest request = new AppointmentRequest();
            request.setRoomId(1);
            request.setPlaceId("place-001");
            request.setPlaceName("Central World");
            request.setDateTime(LocalDateTime.now().plusDays(1));

            when(matchRepository.findById(1)).thenReturn(Optional.of(match));
            when(appointmentRepository.existsByMatch_IdAndStatusIn(eq(1), anyList())).thenReturn(true);

            assertThrows(ConflictException.class,
                    () -> appointmentService.createAppointment("user-001", request));
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // getAppointmentsByRoomId
    // ────────────────────────────────────────────────────────────────────────

    @Nested
    @DisplayName("getAppointmentsByRoomId")
    class GetAppointmentsTests {

        @Test
        @DisplayName("should return appointments for a valid room")
        void getAppointments_success() {
            when(matchRepository.findById(1)).thenReturn(Optional.of(match));
            when(appointmentRepository.findByMatch_Id(1)).thenReturn(List.of(appointment));

            AppointmentListResponse result = appointmentService.getAppointmentsByRoomId("user-001", 1);

            assertNotNull(result);
            assertEquals(1, result.getAppointments().size());
        }

        @Test
        @DisplayName("should throw NotFoundException when room not found")
        void getAppointments_roomNotFound() {
            when(matchRepository.findById(999)).thenReturn(Optional.empty());

            assertThrows(NotFoundException.class,
                    () -> appointmentService.getAppointmentsByRoomId("user-001", 999));
        }

        @Test
        @DisplayName("should throw ForbiddenAccessException when user is not a member")
        void getAppointments_notMember() {
            when(matchRepository.findById(1)).thenReturn(Optional.of(match));

            assertThrows(ForbiddenAccessException.class,
                    () -> appointmentService.getAppointmentsByRoomId("user-999", 1));
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // deleteAppointment (cancel)
    // ────────────────────────────────────────────────────────────────────────

    @Nested
    @DisplayName("deleteAppointment")
    class DeleteAppointmentTests {

        @Test
        @DisplayName("should cancel appointment successfully")
        void deleteAppointment_success() {
            when(appointmentRepository.findByIdWithMatch(100)).thenReturn(Optional.of(appointment));
            when(appointmentRepository.save(any(Appointment.class))).thenReturn(appointment);

            AppointmentResponse result = appointmentService.deleteAppointment("user-001", 100);

            assertNotNull(result);
            assertEquals(AppointmentStatus.CANCELLED, appointment.getStatus());
        }

        @Test
        @DisplayName("should throw NotFoundException when appointment not found")
        void deleteAppointment_notFound() {
            when(appointmentRepository.findByIdWithMatch(999)).thenReturn(Optional.empty());

            assertThrows(NotFoundException.class,
                    () -> appointmentService.deleteAppointment("user-001", 999));
        }

        @Test
        @DisplayName("should throw ForbiddenAccessException when user is not a room member")
        void deleteAppointment_notMember() {
            when(appointmentRepository.findByIdWithMatch(100)).thenReturn(Optional.of(appointment));

            assertThrows(ForbiddenAccessException.class,
                    () -> appointmentService.deleteAppointment("user-999", 100));
        }
    }
}
