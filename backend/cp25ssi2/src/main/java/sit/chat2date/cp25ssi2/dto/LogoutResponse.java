package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LogoutResponse {
    private String message;
    private String status;
}