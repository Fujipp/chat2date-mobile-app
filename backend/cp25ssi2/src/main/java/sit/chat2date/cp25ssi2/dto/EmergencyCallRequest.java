package sit.chat2date.cp25ssi2.dto;

import lombok.Data;
import java.util.List;

@Data
public class EmergencyCallRequest {
    private List<String> phoneNumbers;
}