package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import sit.chat2date.cp25ssi2.entities.*;

import java.util.List;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class PreferenceUserProfileDTO {
    private List<UserHasInterest> interests;
    private List<UserHasLifestyle> lifeStyles;
    private List<UserHasTag> tags;
    private List<UserHasTravelstyle> travelStyles;
    private String interestedGender;
    private List<UserPhoto> photos;
}
