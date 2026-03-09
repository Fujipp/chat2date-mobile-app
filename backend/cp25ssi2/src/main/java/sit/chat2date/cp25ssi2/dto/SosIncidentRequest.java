package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SosIncidentRequest {
    private Integer appointmentId;
    private Double latitude;
    private Double longitude;
    private String calledNumber;
}