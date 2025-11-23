package sit.chat2date.cp25ssi2.dto;

public record DeviceTokenRequest(
        String userId,
        String fcmToken,
        String platform // android / ios
) {}
