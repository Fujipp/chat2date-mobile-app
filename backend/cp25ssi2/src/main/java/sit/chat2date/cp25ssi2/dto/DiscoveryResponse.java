package sit.chat2date.cp25ssi2.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DiscoveryResponse {
    private String userId;
    private String nickname;
    private int age;
    private String sex;
    private List<String> photos;

    // Attributes
    private List<String> tags;
    private List<String> travelStyles;
    private List<String> interests;
    private List<String> lifestyles;

    private double distance;

    // ✨ เพิ่ม Compatibility Score
    private int compatibilityScore;  // 0-100

}


