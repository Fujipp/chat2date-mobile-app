package sit.chat2date.cp25ssi2.services;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.Role;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceptions.PreconditionFailedException;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setUserId("user-001");
        testUser.setEmail("test@example.com");
        testUser.setPhoneNumber("0812345678");
        testUser.setRole(Role.USER);
        testUser.setVersion(1);
        testUser.setDeleteFlag(false);
    }

    // ────────────────────────────────────────────────────────────────────────
    // getAllUsers
    // ────────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("getAllUsers — should return list of all users")
    void getAllUsers_shouldReturnAllUsers() {
        when(userRepository.findAll()).thenReturn(List.of(testUser));

        List<User> result = userService.getAllUsers();

        assertEquals(1, result.size());
        assertEquals("user-001", result.get(0).getUserId());
        verify(userRepository).findAll();
    }

    // ────────────────────────────────────────────────────────────────────────
    // getUserById
    // ────────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("getUserById — should return user when found")
    void getUserById_shouldReturnUser() {
        when(userRepository.findByUserId("user-001")).thenReturn(Optional.of(testUser));

        User result = userService.getUserById("user-001");

        assertEquals("user-001", result.getUserId());
    }

    @Test
    @DisplayName("getUserById — should throw NotFoundException when user not found")
    void getUserById_shouldThrowNotFound() {
        when(userRepository.findByUserId("invalid")).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> userService.getUserById("invalid"));
    }

    // ────────────────────────────────────────────────────────────────────────
    // createUser
    // ────────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("createUser — should save and return new user")
    void createUser_shouldSaveUser() {
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        User result = userService.createUser(testUser);

        assertEquals("user-001", result.getUserId());
        verify(userRepository).save(testUser);
    }

    // ────────────────────────────────────────────────────────────────────────
    // updateUserById
    // ────────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("updateUserById — should throw NotFoundException when user not found")
    void updateUserById_shouldThrowNotFound() {
        when(userRepository.findByUserId("invalid")).thenReturn(Optional.empty());

        User updateData = new User();
        updateData.setVersion(1);

        assertThrows(NotFoundException.class, () -> userService.updateUserById("invalid", updateData));
    }

    @Test
    @DisplayName("updateUserById — should throw PreconditionFailedException on version mismatch")
    void updateUserById_shouldThrowVersionMismatch() {
        when(userRepository.findByUserId("user-001")).thenReturn(Optional.of(testUser));

        User updateData = new User();
        updateData.setVersion(999);

        assertThrows(PreconditionFailedException.class,
                () -> userService.updateUserById("user-001", updateData));
    }

    // ────────────────────────────────────────────────────────────────────────
    // deleteUser
    // ────────────────────────────────────────────────────────────────────────

    @Nested
    @DisplayName("deleteUser")
    class DeleteUserTests {

        @Test
        @DisplayName("should hard-delete when user is ADMIN")
        void deleteUser_admin_shouldHardDelete() {
            testUser.setRole(Role.ADMIN);
            when(userRepository.findByUserId("user-001")).thenReturn(Optional.of(testUser));

            ResponseEntity<Void> result = userService.deleteUser("user-001");

            assertEquals(HttpStatus.NO_CONTENT, result.getStatusCode());
            verify(userRepository).delete(testUser);
        }

        @Test
        @DisplayName("should soft-delete when user is USER")
        void deleteUser_user_shouldSoftDelete() {
            when(userRepository.findByUserId("user-001")).thenReturn(Optional.of(testUser));

            ResponseEntity<Void> result = userService.deleteUser("user-001");

            assertEquals(HttpStatus.NO_CONTENT, result.getStatusCode());
            assertTrue(testUser.getDeleteFlag());
            assertNotNull(testUser.getDeletedAt());
            verify(userRepository).save(testUser);
        }

        @Test
        @DisplayName("should throw when user not found")
        void deleteUser_shouldThrowNotFound() {
            when(userRepository.findByUserId("invalid")).thenReturn(Optional.empty());

            assertThrows(ResponseStatusException.class, () -> userService.deleteUser("invalid"));
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // restoreUser
    // ────────────────────────────────────────────────────────────────────────

    @Nested
    @DisplayName("restoreUser")
    class RestoreUserTests {

        @Test
        @DisplayName("should restore soft-deleted user within 30 days")
        void restoreUser_shouldRestore() {
            testUser.setDeleteFlag(true);
            testUser.setDeletedAt(LocalDateTime.now().minusDays(5));
            when(userRepository.findByUserId("user-001")).thenReturn(Optional.of(testUser));
            when(userRepository.save(any(User.class))).thenReturn(testUser);

            ResponseEntity<User> result = userService.restoreUser("user-001");

            assertEquals(HttpStatus.OK, result.getStatusCode());
            assertFalse(testUser.getDeleteFlag());
            assertNull(testUser.getDeletedAt());
        }

        @Test
        @DisplayName("should throw BAD_REQUEST when user is not deleted")
        void restoreUser_shouldThrowWhenNotDeleted() {
            when(userRepository.findByUserId("user-001")).thenReturn(Optional.of(testUser));

            ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                    () -> userService.restoreUser("user-001"));
            assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        }

        @Test
        @DisplayName("should throw GONE when deletion period expired (>30 days)")
        void restoreUser_shouldThrowWhenExpired() {
            testUser.setDeleteFlag(true);
            testUser.setDeletedAt(LocalDateTime.now().minusDays(31));
            when(userRepository.findByUserId("user-001")).thenReturn(Optional.of(testUser));

            ResponseStatusException ex = assertThrows(ResponseStatusException.class,
                    () -> userService.restoreUser("user-001"));
            assertEquals(HttpStatus.GONE, ex.getStatusCode());
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // getDeletionStatus
    // ────────────────────────────────────────────────────────────────────────

    @Nested
    @DisplayName("getDeletionStatus")
    class DeletionStatusTests {

        @Test
        @DisplayName("should return isDeleted=false for active user")
        void getDeletionStatus_activeUser() {
            when(userRepository.findByUserId("user-001")).thenReturn(Optional.of(testUser));

            Map<String, Object> result = userService.getDeletionStatus("user-001");

            assertEquals(false, result.get("isDeleted"));
        }

        @Test
        @DisplayName("should return deletion details for soft-deleted user")
        void getDeletionStatus_deletedUser() {
            testUser.setDeleteFlag(true);
            testUser.setDeletedAt(LocalDateTime.now().minusDays(10));
            when(userRepository.findByUserId("user-001")).thenReturn(Optional.of(testUser));

            Map<String, Object> result = userService.getDeletionStatus("user-001");

            assertEquals(true, result.get("isDeleted"));
            assertEquals(true, result.get("canRestore"));
            assertTrue((long) result.get("daysRemaining") > 0);
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // isPhoneRegistered
    // ────────────────────────────────────────────────────────────────────────

    @Test
    @DisplayName("isPhoneRegistered — should return true when phone exists")
    void isPhoneRegistered_shouldReturnTrue() {
        when(userRepository.findByPhoneNumber("0812345678")).thenReturn(Optional.of(testUser));

        assertTrue(userService.isPhoneRegistered("0812345678"));
    }

    @Test
    @DisplayName("isPhoneRegistered — should return false when phone not found")
    void isPhoneRegistered_shouldReturnFalse() {
        when(userRepository.findByPhoneNumber("0000000000")).thenReturn(Optional.empty());

        assertFalse(userService.isPhoneRegistered("0000000000"));
    }
}
