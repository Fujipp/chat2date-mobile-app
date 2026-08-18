package sit.chat2date.cp25ssi2.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AppointmentRequest {

    @NotNull(message = "roomId is required")
    private Integer roomId;

    @NotBlank(message = "placeId is required")
    private String placeId;

    @NotBlank(message = "placeName is required")
    private String placeName;

    @NotNull(message = "dateTime is required")
    @Future(message = "dateTime must be a future date/time")
    private LocalDateTime dateTime;
}
