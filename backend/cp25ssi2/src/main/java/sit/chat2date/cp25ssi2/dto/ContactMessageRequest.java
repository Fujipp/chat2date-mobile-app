package sit.chat2date.cp25ssi2.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ContactMessageRequest {

    @Size(max = 100)
    private String contactName;

    @NotBlank
    @Email
    @Size(max = 100)
    private String contactEmail;

    @NotBlank
    @Size(max = 100)
    private String subject;

    @NotBlank
    private String message;
}