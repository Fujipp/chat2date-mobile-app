package sit.chat2date.cp25ssi2.utils;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.AccountStatus;
import sit.chat2date.cp25ssi2.enums.Provider;
import sit.chat2date.cp25ssi2.enums.Role;
import sit.chat2date.cp25ssi2.enums.Sex;

import java.time.LocalDate;

@Component
@RequiredArgsConstructor
public class UserFactory {

    private final CardIdGenerator cardIdGenerator;

    public User createDefaultUser(String email, Provider provider) {
        String generatedCardId = cardIdGenerator.generateTempCardId();

        return User.builder()
                .email(email)
                .provider(provider)
                .version(0)
                .role(Role.USER)
                .accountStatus(AccountStatus.PENDING)
                .behaviorScore(100)
                .isBlacklist(false)
                .firstname("Unknown")
                .lastname("Unknown")
                .nickname("User")
                .cardId(generatedCardId)
                .birthday(LocalDate.of(2000, 1, 1))
                .sex(Sex.MALE)
                .build();
    }

    public User createGoogleUser(String email) {
        return createDefaultUser(email, Provider.GOOGLE);
    }

    public User createPhoneUser(String phoneNumber) {
        User user = createDefaultUser(null, Provider.OTP);
        user.setPhoneNumber(phoneNumber);
        return user;
    }
}
