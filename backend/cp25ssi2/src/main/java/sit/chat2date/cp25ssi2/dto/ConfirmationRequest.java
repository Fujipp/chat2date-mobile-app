package sit.chat2date.cp25ssi2.dto;

import lombok.Data;
import sit.chat2date.cp25ssi2.enums.ConfirmAction;

@Data
public class ConfirmationRequest {
    String placeName;
    ConfirmAction action;
    String mode;
    String userTarget;
}
