package sit.chat2date.cp25ssi2.dto;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data @AllArgsConstructor
public class VerifyFaceResponse {
    private boolean match;
    private double score; // 0..1 (จะ map จาก confidence ของ Azure)
}
