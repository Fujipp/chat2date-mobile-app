package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AuthenticationResponse {
    private UserDTO user;
    private String accessToken;
    private String refreshToken;
}