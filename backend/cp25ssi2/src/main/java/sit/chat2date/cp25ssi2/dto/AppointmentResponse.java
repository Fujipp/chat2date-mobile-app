package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;
import sit.chat2date.cp25ssi2.enums.AppointmentStatus;

import java.time.LocalDateTime;

@Data
@Builder
public class AppointmentResponse {

    private Integer appointmentId;
    private Integer roomId;
    private String placeId;
    private String placeName;
    private LocalDateTime dateTime;
    private AppointmentStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
