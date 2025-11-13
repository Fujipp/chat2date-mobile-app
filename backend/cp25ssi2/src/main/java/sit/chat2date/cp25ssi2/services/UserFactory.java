package sit.chat2date.cp25ssi2.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.AccountStatus;
import sit.chat2date.cp25ssi2.enums.Provider;
import sit.chat2date.cp25ssi2.enums.Role;
import sit.chat2date.cp25ssi2.enums.Sex;

import java.time.LocalDate;

@Component
public class UserFactory {
    @Autowired
    private static AuthService authService;

    public static User createDefaultUser(String email, Provider provider) {
        String generatedCardId = authService.generateTempCardId();

        return User.builder()
                .email(email)
                .provider(provider)
                .version(1)
                .role(Role.USER)
                .accountStatus(AccountStatus.PENDING)
                .isVerify(false)
                .faceVerify(false)
                .behaviorScore(100)
                .isBlacklist(false)
                .firstname("Unknown")
                .lastname("Unknown")
                .nickname("User")
                .cardId(generatedCardId)
                .birthday(LocalDate.of(2000, 1, 1))
                .age(0)
                .sex(Sex.MALE)
                .build();
    }

    public static User createGoogleUser(String email) {
        return createDefaultUser(email, Provider.GOOGLE);
    }

    public static User createPhoneUser(String phoneNumber) {
        User user = createDefaultUser(null, Provider.OTP);
        user.setPhoneNumber(phoneNumber);
        return user;
    }
}
