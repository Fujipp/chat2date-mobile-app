package sit.chat2date.cp25ssi2.services;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sit.chat2date.cp25ssi2.clients.GeminiClient;
import sit.chat2date.cp25ssi2.dto.*;
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
    private final RelationshipStatsRepository relationshipStatsRepository;
    private final ChatAccessLogRepository chatAccessLogRepository;
    private final GeminiClient geminiClient;
    private final ObjectMapper objectMapper;
    private final SimpMessagingTemplate messagingTemplate;

    @Transactional
    public GameStartResponse createGame(Integer roomId, String userId) {
        System.out.println("Processing Game for Room ID: " + roomId);

        Match match = matchRepository.findById(roomId)
                .orElseThrow(() -> new NotFoundException("Match not found")); // Check 404

        boolean isP1 = match.getUserId1() != null && match.getUserId1().getUserId().equals(userId);
        boolean isP2 = match.getUserId2() != null && match.getUserId2().getUserId().equals(userId);

        if (!isP1 && !isP2) {
            throw new ForbiddenAccessException("You are not allowed to create a game for this room."); // Check 403
        }

        try {
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
            List<GameQuestionDTO> questions = objectMapper.readValue(jsonResult, new TypeReference<>() {});

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

                GameQuestions question = new GameQuestions();
                question.setQuestionId(q.getQuestionId());
                question.setGameId(session.getGameId());
                question.setQuestion(text);
                question.setCorrectAnswer(correct);
                question.setOptions(objectMapper.writeValueAsString(newOptions));
                dbQuestions.add(question);
            }
            gameQuestionRepository.saveAll(dbQuestions);

            String myAvatar = userPhotoRepository.findFirstAvatarUrl(userId);

            User partnerUser = isP1 ? match.getUserId2() : match.getUserId1();
            String partnerAvatar = userPhotoRepository.findFirstAvatarUrl(partnerUser.getUserId());

            GameStartResponse response = new GameStartResponse();
            response.setQuestions(questions);
            response.setGameId(session.getGameId());
            response.setMyAvatar(myAvatar);
            response.setPartnerAvatar(partnerAvatar);
            response.setRelationshipScore(0);

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

        String player1Id = (match.getUserId1() != null) ? match.getUserId1().getUserId() : "";
        String player2Id = (match.getUserId2() != null) ? match.getUserId2().getUserId() : "";
        String cleanCurrentUser = currentUserId.trim();

        boolean isPlayer1 = player1Id.equalsIgnoreCase(cleanCurrentUser);
        boolean isPlayer2 = player2Id.equalsIgnoreCase(cleanCurrentUser);

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

        if (isGameOver && session.getStatus() != GameSessionStatus.COMPLETED) {
            session.setStatus(GameSessionStatus.COMPLETED);
            gameSessionRepository.save(session);

            RelationshipStats relStats = relationshipStatsRepository.findByRoomId(roomId)
                    .orElseThrow(() -> new NotFoundException("Relationship stats not found"));

            relStats.setScore(relStats.getScore() + session.getTotalScore());
            relationshipStatsRepository.save(relStats);
        }

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

    public GameCheckResponse checkGameStatus(Integer roomId, String userId) {

        Match match = matchRepository.findById(roomId)
                .orElseThrow(() -> new NotFoundException("Match not found"));

        boolean isP1 = match.getUserId1() != null && match.getUserId1().getUserId().equals(userId);
        boolean isP2 = match.getUserId2() != null && match.getUserId2().getUserId().equals(userId);

        if (!isP1 && !isP2) {
            throw new ForbiddenAccessException("You are not allowed to access this room.");
        }

        Optional<GameSessions> lastSessionOpt = gameSessionRepository.findTopByRoomIdOrderByCreatedAtDesc(roomId.toString());

        if (lastSessionOpt.isEmpty()) {
            return GameCheckResponse.builder().canPlay(true).gameStatus("NEW").build();
        }

        GameSessions lastSession = lastSessionOpt.get();

        if (lastSession.getStatus() == GameSessionStatus.ACTIVE) {
            return GameCheckResponse.builder()
                    .canPlay(true)
                    .gameStatus("RESUME")
                    .gameId(lastSession.getGameId())
                    .build();
        }

        LocalDateTime lastPlayed = lastSession.getCreatedAt();
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime unlockTime = lastPlayed.plusHours(24);

        if (now.isBefore(unlockTime)) {
            long secondsLeft = java.time.Duration.between(now, unlockTime).getSeconds();
            return GameCheckResponse.builder()
                    .canPlay(false)
                    .gameStatus("COOLDOWN")
                    .remainingSeconds(secondsLeft)
                    .build();
        }

        return GameCheckResponse.builder().canPlay(true).gameStatus("NEW").build();
    }

    public GameResumeResponse getGameInfo(String gameId, String userId) {
        GameSessions session = gameSessionRepository.findById(gameId)
                .orElseThrow(() -> new NotFoundException("Game not found"));

        Integer roomId = Integer.valueOf(session.getRoomId());
        Match match = matchRepository.findById(roomId)
                .orElseThrow(() -> new NotFoundException("Match not found"));

        boolean isP1 = match.getUserId1() != null && match.getUserId1().getUserId().equals(userId);
        boolean isP2 = match.getUserId2() != null && match.getUserId2().getUserId().equals(userId);

        if (!isP1 && !isP2) {
            throw new ForbiddenAccessException("You are not allowed to view this game.");
        }

        List<GameQuestions> questionsEntity = gameQuestionRepository.findAllByGameId(gameId);
        List<GameQuestionDTO> questionDTOs = new ArrayList<>();
        try {
            for (GameQuestions q : questionsEntity) {
                GameQuestionDTO dto = new GameQuestionDTO();
                dto.setQuestionId(q.getQuestionId());
                dto.setText(q.getQuestion());
                dto.setCorrect(q.getCorrectAnswer());
                dto.setOptions(objectMapper.readValue(q.getOptions(), new TypeReference<>() {}));
                questionDTOs.add(dto);
            }
        } catch (Exception e) {
            throw new RuntimeException("Error parsing questions");
        }

        List<String> myAnsweredIds = gameAnswerRepository.findQuestionIdsByUserIdAndGameId(userId, gameId);

        User partnerUser = isP1 ? match.getUserId2() : match.getUserId1();
        String myAvatar = userPhotoRepository.findFirstAvatarUrl(userId);
        String partnerAvatar = userPhotoRepository.findFirstAvatarUrl(partnerUser.getUserId());

        Integer relScore = 0;
        Optional<RelationshipStats> statsOpt = relationshipStatsRepository.findByRoomId(roomId);
        if (statsOpt.isPresent()) {
            relScore = statsOpt.get().getScore();

            if (session.getStatus() == GameSessionStatus.COMPLETED) {
                relScore = relScore - session.getTotalScore();
            }
        }

        return GameResumeResponse.builder()
                .gameId(gameId)
                .status(session.getStatus().toString())
                .totalScore(session.getTotalScore())
                .questions(questionDTOs)
                .myAnsweredQuestionIds(myAnsweredIds)
                .myAvatar(myAvatar)
                .partnerAvatar(partnerAvatar)
                .relationshipScore(relScore)
                .build();
    }

    public void checkAndTriggerGame(Integer roomId, int currentScore) {
        int targetScore = 0;
        if (currentScore >= 75) {
            targetScore = 75;
        } else if (currentScore >= 50) {
            targetScore = 50;
        } else if (currentScore >= 25) {
            targetScore = 25;
        }

        if (targetScore == 0) return;

        boolean hasActiveGame = gameSessionRepository.existsByRoomIdAndStatus(
                roomId.toString(), GameSessionStatus.ACTIVE
        );
        if (hasActiveGame) return;

        long completedGamesCount = gameSessionRepository.countByRoomIdAndStatus(
                roomId.toString(), GameSessionStatus.COMPLETED
        );

        boolean shouldTrigger = false;
        if (targetScore == 25 && completedGamesCount == 0) shouldTrigger = true;
        else if (targetScore == 50 && completedGamesCount == 1) shouldTrigger = true;
        else if (targetScore == 75 && completedGamesCount == 2) shouldTrigger = true;

        if (!shouldTrigger) return;

        Match match = matchRepository.findById(roomId).orElseThrow();
        String user1 = match.getUserId1().getUserId();
        String user2 = match.getUserId2().getUserId();

        if (isUserOnline(roomId, user1) && isUserOnline(roomId, user2)) {
            System.out.println("🚀 AUTO TRIGGER GAME Level " + targetScore + " for Room: " + roomId);

            Map<String, Object> payload = new HashMap<>();
            payload.put("type", "GAME_START");
            payload.put("level", targetScore);

            messagingTemplate.convertAndSend("/topic/games/" + roomId, payload);
        }
    }

    private boolean isUserOnline(Integer roomId, String userId) {
        return chatAccessLogRepository.findFirstByRoomIdAndUserIdOrderByCreatedAtDesc(roomId, userId)
                .map(log -> sit.chat2date.cp25ssi2.enums.ChatAccessActionType.ENTER.equals(log.getActionType()))
                .orElse(false);
    }
}