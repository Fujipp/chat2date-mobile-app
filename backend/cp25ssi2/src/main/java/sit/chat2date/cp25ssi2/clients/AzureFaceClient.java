package sit.chat2date.cp25ssi2.clients;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.util.*;

@Component
@RequiredArgsConstructor
public class AzureFaceClient {

    private final RestTemplate restTemplate;

    @Value("${azure.faceEndpoint}")
    private String faceEndpoint;

    @Value("${azure.faceApiKey}")
    private String faceApiKey;

    private String detectUrl() {
        // ปรับ v1.0/v1.1/v1.2 ให้ตรงทรัพยากรของ Dev
        return faceEndpoint + "/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false";
    }

    private String verifyUrl() {
        return faceEndpoint + "/face/v1.0/verify";
    }

    /** return: map ของ face detect (ถ้าไม่เจอหน้า -> map ว่าง) */
    public Map<String, Object> detectFace(String imageBase64) {
        byte[] bytes = Base64.getDecoder().decode(imageBase64);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.set("Ocp-Apim-Subscription-Key", faceApiKey);

        HttpEntity<byte[]> entity = new HttpEntity<>(bytes, headers);
        ResponseEntity<List> resp = restTemplate.exchange(detectUrl(), HttpMethod.POST, entity, List.class);

        List list = Optional.ofNullable(resp.getBody()).orElse(Collections.emptyList());
        if (list.isEmpty()) return Collections.emptyMap();
        return (Map<String, Object>) list.get(0);
    }

    /** verify 1:1 → คืน map {isIdentical, confidence} ของ Azure */
    public Map<String, Object> verify(String faceId1, String faceId2) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Ocp-Apim-Subscription-Key", faceApiKey);

        Map<String, String> body = Map.of("faceId1", faceId1, "faceId2", faceId2);
        HttpEntity<Map<String, String>> entity = new HttpEntity<>(body, headers);

        ResponseEntity<Map> resp = restTemplate.exchange(verifyUrl(), HttpMethod.POST, entity, Map.class);
        return resp.getBody() == null ? Collections.emptyMap() : resp.getBody();
    }

    /** ครอปหน้าออกจากรูปบัตร (base64) โดยใช้ faceRectangle จาก detect */
    public String cropIdFaceBase64(String idFrontBase64) {
        Map<String, Object> detected = detectFace(idFrontBase64);
        if (detected.isEmpty() || !detected.containsKey("faceRectangle")) return null;

        Map<String, Integer> rect = (Map<String, Integer>) detected.get("faceRectangle");
        int left = rect.getOrDefault("left", 0);
        int top = rect.getOrDefault("top", 0);
        int width = rect.getOrDefault("width", 0);
        int height = rect.getOrDefault("height", 0);

        try {
            byte[] bytes = Base64.getDecoder().decode(idFrontBase64);
            BufferedImage img = ImageIO.read(new ByteArrayInputStream(bytes));
            left = Math.max(0, left);
            top = Math.max(0, top);
            width = Math.min(width, img.getWidth() - left);
            height = Math.min(height, img.getHeight() - top);
            BufferedImage crop = img.getSubimage(left, top, width, height);

            java.io.ByteArrayOutputStream out = new java.io.ByteArrayOutputStream();
            ImageIO.write(crop, "jpg", out);
            return Base64.getEncoder().encodeToString(out.toByteArray());
        } catch (Exception e) {
            return null;
        }
    }
}
