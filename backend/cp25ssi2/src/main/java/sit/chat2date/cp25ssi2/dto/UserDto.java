package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;

@Builder
@Data
public class UserDto {
    private Integer id;
    private String email;
    private String name;
}