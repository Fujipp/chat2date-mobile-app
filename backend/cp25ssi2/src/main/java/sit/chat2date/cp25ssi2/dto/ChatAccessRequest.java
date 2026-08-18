package sit.chat2date.cp25ssi2.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import sit.chat2date.cp25ssi2.enums.ChatAccessActionType;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatAccessRequest {
    @NotBlank(message = "roomId is required")
    private String roomId;

    @NotBlank(message = "userId is required")
    private String userId;

    private ChatAccessActionType type;
}
