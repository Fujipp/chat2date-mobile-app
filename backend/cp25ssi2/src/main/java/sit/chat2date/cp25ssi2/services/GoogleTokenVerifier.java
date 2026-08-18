package sit.chat2date.cp25ssi2.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;

import java.util.Map;

@Component
public class GoogleTokenVerifier {

    @Value("${google.client-id}")
    private String clientId;

    private final RestTemplate restTemplate = new RestTemplate();

    public Map<String, Object> verify(String idToken) throws Exception {
        String url = "https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken;

        try {
            ResponseEntity<Map> response = restTemplate.getForEntity(url, Map.class);
            Map<String, Object> payload = response.getBody();

            if (payload == null) {
                return null;
            }

            String aud = (String) payload.get("aud");
            if (!clientId.equals(aud)) {
                return null;
            }

            return payload;

        } catch (Exception e) {
            throw new Exception("Invalid Google token", e);
        }
    }
}