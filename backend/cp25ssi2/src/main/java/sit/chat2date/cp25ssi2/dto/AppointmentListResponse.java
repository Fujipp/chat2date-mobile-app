package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class AppointmentListResponse {

    private List<AppointmentResponse> appointments;
}
