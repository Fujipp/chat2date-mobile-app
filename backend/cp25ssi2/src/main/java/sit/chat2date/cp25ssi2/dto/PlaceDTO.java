package sit.chat2date.cp25ssi2.dto;

import lombok.Data;

@Data
public class PlaceDTO {
    private String googlePlaceId;
    private String name;
    private double latitude;
    private double longitude;
    private String address;
    private String imageUrl;

    public PlaceDTO(String id, String name, double lat, double lng, String address, String imageUrl) {
        this.googlePlaceId = id;
        this.name = name;
        this.latitude = lat;
        this.longitude = lng;
        this.address = address;
        this.imageUrl = imageUrl;
    }
}
