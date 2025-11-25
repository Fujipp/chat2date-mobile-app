package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;

@Builder
@Data
public class UserDTO {
    private String id;
    private String email;
    private String phoneNumber;
    private String accountStatus;
    private Integer version;
}