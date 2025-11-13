package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RefreshTokenResponse {
    private String accessToken;
    private String tokenType = "Bearer";

    public RefreshTokenResponse(String accessToken) {
        this.accessToken = accessToken;
    }
}