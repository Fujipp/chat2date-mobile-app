package sit.chat2date.cp25ssi2.services;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.clients.GeminiClient;
import sit.chat2date.cp25ssi2.dto.GameQuestionDTO;
import sit.chat2date.cp25ssi2.dto.GameStartResponse;
import sit.chat2date.cp25ssi2.entities.Message;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.repositories.MessageRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.util.*;

@Service
@RequiredArgsConstructor
public class GameService {
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final GeminiClient geminiClient;
    private final ObjectMapper objectMapper;

    public GameStartResponse createGame(Integer roomId) {
        System.out.println("Processing Game for Room ID: " + roomId);

        List<Message> messages = messageRepository.findLast50ByRoomIdOrderByCreatedAtDesc(roomId);
        Collections.reverse(messages);

        Map<String, String> idToPlaceholder = new HashMap<>();     // เก็บ UUID -> Person A
        Map<String, String> placeholderToNickname = new HashMap<>(); // เก็บ Person A -> "น้องโบว์" (ใช้ตอนถอดหน้ากาก)

        String[] placeholders = {"Person A", "Person B"}; // นามแฝง
        int counter = 0;

        StringBuilder chatLogForAI = new StringBuilder();

        for (Message msg : messages) {
            String senderId = msg.getSenderId();
            if (!idToPlaceholder.containsKey(senderId)) {
                String ph = placeholders[counter % 2];
                idToPlaceholder.put(senderId, ph);
                counter++;

                User user = userRepository.findById(senderId).orElse(null);
                String realNickname = (user != null && user.getNickname() != null) ? user.getNickname() : "Unknown";
                placeholderToNickname.put(ph, realNickname);
            }

            // ✅ สร้าง Chat Log โดยใช้ชื่อ "Person A/B" เท่านั้น (AI จะไม่เห็นชื่อจริง)
            String ph = idToPlaceholder.get(senderId);
            chatLogForAI.append(ph).append(": ").append(msg.getMessage()).append("\n");
        }

        String jsonResult = geminiClient.generateQuestions(chatLogForAI.toString());

        try {
            List<GameQuestionDTO> questions = objectMapper.readValue(
                    jsonResult,
                    new TypeReference<>() {
                    }
            );

            for (GameQuestionDTO q : questions) {
                q.setQuestionId(UUID.randomUUID().toString());

                String text = q.getText();
                String correct = q.getCorrect();
                List<String> options = q.getOptions();
                List<String> newOptions = new ArrayList<>();

                for (Map.Entry<String, String> entry : placeholderToNickname.entrySet()) {
                    String placeholder = entry.getKey();
                    String nickname = entry.getValue();

                    if (text != null) text = text.replace(placeholder, nickname);
                    if (correct != null) correct = correct.replace(placeholder, nickname);
                }

                for (String opt : options) {
                    String newOpt = opt;
                    for (Map.Entry<String, String> entry : placeholderToNickname.entrySet()) {
                        newOpt = newOpt.replace(entry.getKey(), entry.getValue());
                    }
                    newOptions.add(newOpt);
                }

                q.setText(text);
                q.setCorrect(correct);
                q.setOptions(newOptions);
            }



            GameStartResponse response = new GameStartResponse();
            response.setQuestions(questions);
            response.setGameId(UUID.randomUUID().toString());

            return response;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Error processing AI response: " + e.getMessage());
        }
    }
}