package sit.chat2date.cp25ssi2.dto;
import lombok.Data;

@Data
public class VerifyFaceRequest {
    private String selfieBase64;   // เซลฟี่ base64
    private String idFaceBase64;   // หน้าจากบัตร (base64)
}
