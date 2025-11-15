package sit.chat2date.cp25ssi2.dto;

import lombok.Builder;
import lombok.Data;
import sit.chat2date.cp25ssi2.entities.Interest;
import sit.chat2date.cp25ssi2.entities.LifeStyle;
import sit.chat2date.cp25ssi2.entities.Tag;
import sit.chat2date.cp25ssi2.entities.TravelStyle;

import java.util.List;

@Builder
@Data
public class PreferenceDto {
    private List<Interest> interests;
    private List<LifeStyle> lifeStyles;
    private List<Tag> tags;
    private List<TravelStyle> travelStyles;
}
