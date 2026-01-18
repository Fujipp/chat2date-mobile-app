package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import sit.chat2date.cp25ssi2.enums.ReportStatus;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportResponse {
    private String reportId;
    private String reporterId;
    private String targetUserId;
    private String reason;
    private ReportStatus status;
    private LocalDateTime createdAt;
}
