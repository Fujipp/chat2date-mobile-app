package sit.chat2date.cp25ssi2.dto;

import lombok.Data;

@Data
public class PlaceDTO {
    private String name;
    private double latitude;
    private double longitude;
    private String address;

    public PlaceDTO(String name, double lat, double lng, String address) {
        this.name = name;
        this.latitude = lat;
        this.longitude = lng;
        this.address = address;
    }
}
