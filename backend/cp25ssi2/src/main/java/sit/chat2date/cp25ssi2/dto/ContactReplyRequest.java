package sit.chat2date.cp25ssi2.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ContactReplyRequest {

    @NotBlank
    private String replyMessage;
}