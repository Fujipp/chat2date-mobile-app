package sit.chat2date.cp25ssi2.clients;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.util.*;

@RestController
@RequestMapping(("/demo"))
public class GeminiClient {
    @Value("${gemini.apiKey}")
    private String apiKey;
//    // ใช้ Model Flash เพราะเร็วและฟรี (หรือเปลี่ยนเป็น gemini-1.5-pro ก็ได้)
//    private final String GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + apiKey;

    @GetMapping("/ask-ai")
    public String askGemini() {
        String geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;

        RestTemplate restTemplate = new RestTemplate();

        // 2. เตรียมคำสั่ง (Prompt)
        // บังคับให้ตอบเป็น JSON Array เท่านั้น
        String prompt = "Generate 1 funny dating question with 4 options. in Thai language Return ONLY raw JSON. Format: [{\"question\":\"...\", \"options\":[\"A\",\"B\",\"C\",\"D\"], \"correct\":\"A\"}]";

        // 3. สร้าง Body ตาม Format ของ Google
        Map<String, Object> requestBody = Map.of(
                "contents", List.of(
                        Map.of("parts", List.of(Map.of("text", prompt)))
                )
        );

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            // 4. ยิงไปหา Google
            ResponseEntity<Map> response = restTemplate.postForEntity(geminiUrl, entity, Map.class);

            // 5. แกะกล่องของขวัญ (JSON ที่ Google ส่งกลับมาซ้อนหลายชั้น)
            // path: candidates[0].content.parts[0].text
            Map body = response.getBody();
            List candidates = (List) body.get("candidates");
            Map firstCandidate = (Map) candidates.get(0);
            Map content = (Map) firstCandidate.get("content");
            List parts = (List) content.get("parts");
            Map firstPart = (Map) parts.get(0);
            String text = (String) firstPart.get("text");

            // 6. ส่งข้อความ Clean ๆ กลับไปให้ Flutter
            return text
                    .replace("```json", "") // ล้าง Markdown
                    .replace("```", "")
                    .trim();

        } catch (Exception e) {
            e.printStackTrace();
            return "{\"error\": \"Failed to connect Gemini\"}";
        }
    }
}
