package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;
import sit.chat2date.cp25ssi2.entities.User;

@Data
@Builder
public class AuthenticationResponse {
    private UserDto user;
    private String accessToken;
    private String refreshToken;
}