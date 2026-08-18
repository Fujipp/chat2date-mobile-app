package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import sit.chat2date.cp25ssi2.entities.User;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class PreferenceMatchUserDTO {
    private String interestedGender;
    private Integer interestedAgeMax;
    private Integer interestedAgeMin;
    private User user;
    private String interestedTravelStyle;
    private String interestedLifeStyle;
    private String interestedInterest;
    private Integer interestedDistanceMin;
    private Integer interestedDistanceMax;
}
