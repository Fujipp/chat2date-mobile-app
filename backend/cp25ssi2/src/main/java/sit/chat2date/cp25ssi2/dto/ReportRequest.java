package sit.chat2date.cp25ssi2.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportRequest {
    @NotBlank(message = "userId is required")
    private String userId;

    @NotBlank(message = "targetUserId is required")
    private String targetUserId;

    @NotBlank(message = "reason is required")
    private String reason;

    private String anotherReason;

    private String description;
}
