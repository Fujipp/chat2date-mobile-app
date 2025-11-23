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
    private List<Integer> interests;
    private List<Integer> lifeStyles;
    private List<Integer> tags;
    private List<Integer> travelStyles;
    private String interestedGender;
    private String photos;
}
