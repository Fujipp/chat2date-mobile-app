package sit.chat2date.cp25ssi2.clients;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class FaceVerificationClient {

    private final RestTemplate restTemplate;

    @Value("${iapp.face.endpoint}")
    private String endpoint;

    @Value("${iapp.face.apikey}")
    private String apiKey;

    /**
     * ส่งรูป 2 รูป (byte[]) ไปเทียบกันที่ iApp
     * imageBytes1 = รูปบัตรประชาชน (Source)
     * imageBytes2 = รูปโปรไฟล์ (Target)
     */
    public boolean verify(byte[] imageBytes1, byte[] imageBytes2) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA); // สำคัญมาก
            headers.set("apikey", apiKey);

            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();

            body.add("file1", new NamedByteArrayResource(imageBytes1, "id_card.jpg"));
            body.add("file2", new NamedByteArrayResource(imageBytes2, "profile.jpg"));


            HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

            ResponseEntity<Map> response = restTemplate.postForEntity(endpoint, requestEntity, Map.class);

            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                Map<String, Object> result = response.getBody();
                return (Boolean) result.getOrDefault("matched", false);
            }
        } catch (Exception e) {
            System.err.println("Face Verification Error: " + e.getMessage());
        }
        return false;
    }

    // --- Inner Class เพื่อช่วยตั้งชื่อไฟล์ตอนส่ง Multipart ---
    static class NamedByteArrayResource extends ByteArrayResource {
        private final String filename;

        public NamedByteArrayResource(byte[] content, String filename) {
            super(content);
            this.filename = filename;
        }

        @Override
        public String getFilename() {
            return this.filename;
        }
    }
}