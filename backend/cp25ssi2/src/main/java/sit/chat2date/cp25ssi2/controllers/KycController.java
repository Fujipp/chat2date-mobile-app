package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.clients.AzureFaceClient;
import sit.chat2date.cp25ssi2.clients.ThaiIdOcrClient;
import sit.chat2date.cp25ssi2.dto.*;

import java.util.Map;

@RestController
@RequestMapping("/kyc")
@RequiredArgsConstructor
public class KycController {

    private final ThaiIdOcrClient ocrClient;
    private final AzureFaceClient faceClient;

    @PostMapping("/ocr-thaiid")
    public ResponseEntity<Map<String, Object>> ocrThaiId(@RequestBody OcrThaiIdRequest req) {
        Map<String, Object> body = ocrClient.ocrFront(req.getImageBase64());
        return ResponseEntity.ok(body);
    }

    @PostMapping("/ocr/crop-id-face")
    public ResponseEntity<Map<String, Object>> cropIdFace(@RequestBody CropIdFaceRequest req) {
        String idFaceB64 = faceClient.cropIdFaceBase64(req.getIdFrontBase64());
        return ResponseEntity.ok(Map.of("idFaceBase64", idFaceB64));
    }

    @PostMapping("/verify-face")
    public ResponseEntity<VerifyFaceResponse> verify(@RequestBody VerifyFaceRequest req) {
        Map<String, Object> d1 = faceClient.detectFace(req.getSelfieBase64());
        String faceId1 = d1.getOrDefault("faceId", "").toString();
        if (faceId1.isEmpty()) return ResponseEntity.ok(new VerifyFaceResponse(false, 0.0));

        Map<String, Object> d2 = faceClient.detectFace(req.getIdFaceBase64());
        String faceId2 = d2.getOrDefault("faceId", "").toString();
        if (faceId2.isEmpty()) return ResponseEntity.ok(new VerifyFaceResponse(false, 0.0));

        Map<String, Object> v = faceClient.verify(faceId1, faceId2);
        boolean isIdentical = Boolean.TRUE.equals(v.get("isIdentical"));
        double score = v.get("confidence") instanceof Number ? ((Number) v.get("confidence")).doubleValue() : 0.0;

        boolean match = isIdentical && score >= 0.80; // threshold ปรับได้
        return ResponseEntity.ok(new VerifyFaceResponse(match, score));
    }
}
