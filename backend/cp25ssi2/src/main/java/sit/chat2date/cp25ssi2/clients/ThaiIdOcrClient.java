package sit.chat2date.cp25ssi2.clients;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.Base64;
import java.util.Collections;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class ThaiIdOcrClient {

    private final RestTemplate restTemplate;

    @Value("${thaiid.endpoint}")
    private String endpoint;

    @Value("${thaiid.apiKey}")
    private String apiKey;

    public Map<String, Object> ocrFront(String imageBase64) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("x-api-key", apiKey);

        Map<String, Object> body = Map.of("image", imageBase64);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

        ResponseEntity<Map> resp = restTemplate.exchange(endpoint, HttpMethod.POST, entity, Map.class);
        return resp.getBody() == null ? Collections.emptyMap() : resp.getBody();
    }
}
