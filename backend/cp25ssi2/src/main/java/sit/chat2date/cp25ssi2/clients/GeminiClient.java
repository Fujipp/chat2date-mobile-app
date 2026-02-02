package sit.chat2date.cp25ssi2.clients;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.util.*;

@Service
public class GeminiClient {

    @Value("${gemini.apiKey}")
    private String apiKey;

    public String generateQuestions(String chatLog) {
        String modelName = "gemini-2.5-flash";
        String geminiUrl = String.format(
                "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
                modelName, apiKey
        );

        RestTemplate restTemplate = new RestTemplate();

        // Prompt
        String prompt = "Analyze the following chat history and generate 5 multiple-choice trivia questions to test how well the users know each other. In Thai language only\n" +
                "\n" +
                "Chat History:\n" +
                chatLog + "\n" +
                "\n" +
                "Strict Rules:\n" +
                "1. Questions must be based **STRICTLY AND ONLY** on facts explicitly mentioned in the chat history.\n" +
                "2. **DO NOT** invent, hallucinate, or assume details that are not in the text. (e.g. Do not mention Liverpool or Elden Ring if not explicitly said).\n" +
                "3. If the chat is in Thai, generate questions and options in **Thai**. If English, use English.\n" +
                "4. Return ONLY a raw JSON Array. Do not use Markdown code blocks (```json).\n" +
                "5. JSON Format: [{\"question\":\"...\", \"options\":[\"Option A\",\"Option B\",\"Option C\",\"Option D\"], \"correct\":\"Option A\"}]\n" +
                "6. The 'correct' field must match exactly one of the strings in 'options'.";

        System.out.println("==========================================");
        System.out.println("DEBUG CHAT LOG (Sending to AI):");
        System.out.println(chatLog);
        System.out.println("==========================================");

        Map<String, Object> requestBody = Map.of(
                "contents", List.of(
                        Map.of("parts", List.of(Map.of("text", prompt)))
                )
        );

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(geminiUrl, entity, Map.class);

            // แกะ Response
            Map body = response.getBody();
            List candidates = (List) body.get("candidates");
            Map firstCandidate = (Map) candidates.get(0);
            Map content = (Map) firstCandidate.get("content");
            List parts = (List) content.get("parts");
            Map firstPart = (Map) parts.get(0);
            String text = (String) firstPart.get("text");

            return text.replace("```json", "").replace("```", "").trim();

        } catch (Exception e) {
            e.printStackTrace();
            // ใน Service จริง อาจจะ throw exception ให้ Controller รู้ว่า Gen ไม่ผ่าน
            throw new RuntimeException("Gemini generation failed: " + e.getMessage());
        }
    }
}