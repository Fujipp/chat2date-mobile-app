package sit.chat2date.cp25ssi2.dto;

import lombok.Data;

@Data
public class UpdateLocationRequest {
    private double latitude;
    private double longitude;
    private double accuracy;
}
