package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.dto.AuthenticationResponse;
import sit.chat2date.cp25ssi2.dto.UserDto;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.AccountStatus;
import sit.chat2date.cp25ssi2.enums.Provider;
import sit.chat2date.cp25ssi2.enums.Role;
import sit.chat2date.cp25ssi2.enums.Sex;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.time.LocalDate;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final GoogleTokenVerifier googleTokenVerifier;
    private final JwtTokenUtil jwtTokenUtil;

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
        } else {
            user = UserFactory.createGoogleUser(email);
            user = userRepository.save(user);
        }

        String accessToken = jwtTokenUtil.generateToken(email);
        String refreshToken = jwtTokenUtil.generateRefreshToken(user.getUserId());

        UserDto userDto = UserDto.builder()
                .id(user.getUserId())
                .email(user.getEmail())
                .build();

        return AuthenticationResponse.builder()
                .user(userDto)
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    public String generateTempCardId() {
        // Format: 000 + timestamp (9 หลัก) + random (1 หลัก) = 13 หลัก
        long timestamp = System.currentTimeMillis();
        String timestampStr = String.valueOf(timestamp);

        // เอา 9 หลักท้าย
        String last9 = timestampStr.substring(timestampStr.length() - 9);

        // เพิ่ม random 1 หลัก เพื่อป้องกัน collision
        int random = (int) (Math.random() * 10);

        return String.format("000%s%d", last9, random);
    }
}