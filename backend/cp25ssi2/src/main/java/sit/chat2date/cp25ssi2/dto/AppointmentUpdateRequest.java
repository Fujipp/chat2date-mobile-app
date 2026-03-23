package sit.chat2date.cp25ssi2.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AppointmentUpdateRequest {

    @NotNull(message = "dateTime is required")
    @Future(message = "dateTime must be a future date/time")
    private LocalDateTime dateTime;
}
