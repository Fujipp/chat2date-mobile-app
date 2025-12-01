package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.utils.UserFactory;
import sit.chat2date.cp25ssi2.dto.AuthenticationResponse;
import sit.chat2date.cp25ssi2.dto.UserDTO;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.Provider;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final GoogleTokenVerifier googleTokenVerifier;
    private final JwtTokenUtil jwtTokenUtil;
    private final UserFactory userFactory;

    public AuthenticationResponse verifyGoogleToken(String idToken) {

        Map<String, Object> payload;
        try {
            payload = googleTokenVerifier.verify(idToken);
            if (payload == null) {
                throw new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "GOOGLE_TOKEN_INVALID"
                );
            }
        } catch (Exception e) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "GOOGLE_TOKEN_INVALID"
            );
        }

        String email = (String) payload.get("email");

        Optional<User> userOptional = userRepository.findByEmail(email);

        User user;
        if (userOptional.isPresent()) {
            user = userOptional.get();

            if (!Provider.GOOGLE.equals(user.getProvider())) {
                throw new ResponseStatusException(
                        HttpStatus.CONFLICT,
                        "EMAIL_LINKED_TO_OTHER_PROVIDER"
                );
            }

            // ✅ เช็คว่าบัญชีถูกลบหรือไม่
            if (Boolean.TRUE.equals(user.getDeleteFlag())) {
                LocalDateTime deletedAt = user.getDeletedAt();
                LocalDateTime now = LocalDateTime.now();
                long daysRemaining = 30 - Duration.between(deletedAt, now).toDays();

                if (daysRemaining <= 0) {
                    // เกิน 30 วัน - บัญชีหมดอายุ
                    throw new ResponseStatusException(
                            HttpStatus.GONE,
                            "ACCOUNT_PERMANENTLY_DELETED"
                    );
                }

                // ยังไม่เกิน 30 วัน - ส่งข้อมูลให้ frontend แสดง dialog
                Map<String, Object> errorDetails = new HashMap<>();
                errorDetails.put("error", "ACCOUNT_DELETED");
                errorDetails.put("isDeleted", true);
                errorDetails.put("deletedAt", deletedAt.toString());
                errorDetails.put("daysRemaining", daysRemaining);
                errorDetails.put("canRestore", true);
                errorDetails.put("userId", user.getUserId());

                throw new AccountDeletedException(errorDetails);
            }

        } else {
            user = userFactory.createGoogleUser(email);
            user = userRepository.save(user);
        }

        String accessToken = jwtTokenUtil.generateToken(email);
        String refreshToken = jwtTokenUtil.generateRefreshToken(user.getUserId());

        UserDTO userDto = UserDTO.builder()
                .id(user.getUserId())
                .email(user.getEmail())
                .accountStatus(user.getAccountStatus().toString())
                .version(user.getVersion())
                .build();

        return AuthenticationResponse.builder()
                .user(userDto)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    // ✅ Custom Exception สำหรับบัญชีที่ถูกลบ
    public static class AccountDeletedException extends RuntimeException {
        private final Map<String, Object> details;

        public AccountDeletedException(Map<String, Object> details) {
            super("Account has been deleted");
            this.details = details;
        }

        public Map<String, Object> getDetails() {
            return details;
        }
    }
}