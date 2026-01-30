package sit.chat2date.cp25ssi2.services;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sit.chat2date.cp25ssi2.clients.GeminiClient;
import sit.chat2date.cp25ssi2.dto.GameAnswerRequest;
import sit.chat2date.cp25ssi2.dto.GameAnswerResponse;
import sit.chat2date.cp25ssi2.dto.GameQuestionDTO;
import sit.chat2date.cp25ssi2.dto.GameStartResponse;
import sit.chat2date.cp25ssi2.entities.*;
import sit.chat2date.cp25ssi2.enums.GameSessionStatus;
import sit.chat2date.cp25ssi2.exceptions.ConflictException;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.*;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
public class GameService {
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final GameQuestionRepository gameQuestionRepository;
    private final GameAnswerRepository gameAnswerRepository;
    private final GameSessionRepository gameSessionRepository;
    private final MatchRepository matchRepository;
    private final UserPhotoRepository userPhotoRepository;
    private final GeminiClient geminiClient;
    private final ObjectMapper objectMapper;
    private final SimpMessagingTemplate messagingTemplate;

    public GameStartResponse createGame(Integer roomId,String userId) {
        System.out.println("Processing Game for Room ID: " + roomId);

        List<Message> messages = messageRepository.findLast50ByRoomIdOrderByCreatedAtDesc(roomId);
        Collections.reverse(messages);

        Map<String, String> idToPlaceholder = new HashMap<>();
        Map<String, String> placeholderToNickname = new HashMap<>();

        String[] placeholders = {"Person A", "Person B"};
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

            GameSessions session = new GameSessions();
            session.setRoomId(roomId.toString());
            session.setStatus(GameSessionStatus.ACTIVE);
            session.setTotalScore(0);
            session.setCreatedAt(LocalDateTime.now());
            session = gameSessionRepository.save(session);

            List<GameQuestions> dbQuestions = new ArrayList<>();

            for (GameQuestionDTO q : questions) {
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
                q.setQuestionId(UUID.randomUUID().toString());


                GameQuestions entity = new GameQuestions();
                entity.setGameId(session.getGameId());
                entity.setQuestion(text);
                entity.setCorrectAnswer(correct);
                entity.setOptions(objectMapper.writeValueAsString(newOptions));

                dbQuestions.add(entity);
            }

            gameQuestionRepository.saveAll(dbQuestions);
            Match match = matchRepository.findById(roomId)
                    .orElseThrow(() -> new NotFoundException("Match not found"));
            String myAvatar = userPhotoRepository.findFirstAvatarUrl(userId);

            User partnerUser;
            if (match.getUserId1().getUserId().equals(userId)) {
                partnerUser = match.getUserId2();
            }else {
                partnerUser = match.getUserId1();
            }

            String partnerAvatar = userPhotoRepository.findFirstAvatarUrl(partnerUser.getUserId());

            GameStartResponse response = new GameStartResponse();
            response.setQuestions(questions);
            response.setGameId(session.getGameId());
            response.setMyAvatar(myAvatar);
            response.setPartnerAvatar(partnerAvatar);

            return response;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Error processing AI response: " + e.getMessage());
        }
    }

    @Transactional
    public GameAnswerResponse answerQuestion(GameAnswerRequest request, String currentUserId) {

        String gameId = request.getGameId();
        String questionId = request.getQuestionId();
        String selectedOption = request.getSelectedOption();

        boolean alreadyAnswered = gameAnswerRepository.existsByUserIdAndQuestionId(currentUserId, questionId);
        if (alreadyAnswered) {
            throw new ConflictException("You have already answered this question.");
        }

        GameSessions session = gameSessionRepository.findById(gameId)
                .orElseThrow(() -> new NotFoundException("Game Session not found: " + gameId));

        if (session.getStatus().equals(GameSessionStatus.COMPLETED)) {
            throw new ConflictException("Game is already finished.");
        }

        Integer roomId = Integer.valueOf(session.getRoomId());

        Match match = matchRepository.findById(roomId)
                .orElseThrow(() -> new NotFoundException("Match not found"));

        // [DEBUG]
        System.out.println("==== DEBUG PERMISSION ====");
        String player1IdFromObj = (match.getUserId1() != null) ? match.getUserId1().getUserId() : "null";
        String player2IdFromObj = (match.getUserId2() != null) ? match.getUserId2().getUserId() : "null";

        System.out.println("Current User: [" + currentUserId + "]");
        System.out.println("Player 1 ID : [" + player1IdFromObj + "]");
        System.out.println("Player 2 ID : [" + player2IdFromObj + "]");

        String cleanCurrentUser = currentUserId.trim();

        String cleanPlayer1 = match.getUserId1() != null ? match.getUserId1().getUserId() : "";
        String cleanPlayer2 = match.getUserId2() != null ? match.getUserId2().getUserId() : "";

        boolean isPlayer1 = cleanPlayer1.equalsIgnoreCase(cleanCurrentUser);
        boolean isPlayer2 = cleanPlayer2.equalsIgnoreCase(cleanCurrentUser);

        System.out.println("Is Player 1? : " + isPlayer1);
        System.out.println("Is Player 2? : " + isPlayer2);
        System.out.println("==========================");

        if (!isPlayer1 && !isPlayer2) {
            throw new ForbiddenAccessException("You are not allowed to answer this question.");
        }

        GameQuestions question = gameQuestionRepository.findById(questionId)
                .orElseThrow(() -> new NotFoundException("Question not found: " + questionId));

        boolean isCorrect = question.getCorrectAnswer().trim().equalsIgnoreCase(selectedOption.trim());

        GameAnswers answer = new GameAnswers();
        answer.setGameSessions(session);
        answer.setQuestion(question);
        answer.setUserId(currentUserId);
        answer.setSelectedOption(selectedOption);
        answer.setIsCorrect(isCorrect);
        gameAnswerRepository.save(answer);

        if (isCorrect) {
            session.setTotalScore(session.getTotalScore() + 1);
            gameSessionRepository.save(session);
        }

        int myAnsweredCount = gameAnswerRepository.countByGameIdAndUserId(gameId, currentUserId);
        int totalQuestions = gameQuestionRepository.countByGameId(gameId);
        boolean isGameOver = myAnsweredCount >= totalQuestions;

        Map<String, Object> socketPayload = new HashMap<>();
        socketPayload.put("type", "SCORE_UPDATE");
        socketPayload.put("roomTotalScore", session.getTotalScore());
        socketPayload.put("answeredBy", currentUserId);
        socketPayload.put("isCorrect", isCorrect);

        messagingTemplate.convertAndSend("/topic/games/" + gameId, socketPayload);

        return GameAnswerResponse.builder()
                .isCorrect(isCorrect)
                .correctAnswer(question.getCorrectAnswer())
                .totalScore(session.getTotalScore())
                .isGameOver(isGameOver)
                .build();
    }
}