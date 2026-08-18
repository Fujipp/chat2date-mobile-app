package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sit.chat2date.cp25ssi2.dto.DeviceTokenRequest;
import sit.chat2date.cp25ssi2.entities.DeviceToken;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.repositories.DeviceTokenRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DeviceTokenService {

    private final DeviceTokenRepository deviceTokenRepository;
    private final UserRepository userRepository;

    @Transactional
    public void registerToken(DeviceTokenRequest request) {
        User user = userRepository.findById(request.userId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // กันกรณี token นี้ถูกเก็บแล้ว
        deviceTokenRepository
                .findByUserAndFcmToken(user, request.fcmToken())
                .orElseGet(() -> {
                    DeviceToken token = new DeviceToken();
                    token.setUser(user);
                    token.setFcmToken(request.fcmToken());
                    token.setPlatform(request.platform());
                    return deviceTokenRepository.save(token);
                });
    }

    @Transactional
    public void removeToken(DeviceTokenRequest request) {
        User user = userRepository.findById(request.userId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        deviceTokenRepository.deleteByUserAndFcmToken(user, request.fcmToken());
    }

    public List<String> getTokensForUser(String userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return deviceTokenRepository.findByUser(user)
                .stream()
                .map(DeviceToken::getFcmToken)
                .collect(Collectors.toList());
    }
}
