package sit.chat2date.cp25ssi2.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.dto.MatchEventPayload;
import sit.chat2date.cp25ssi2.dto.PhotoDTO;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.repositories.UserPhotoRepository;

import java.time.Instant;
import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MatchSocketService {

    private final SimpMessagingTemplate messagingTemplate;
    private final UserPhotoRepository userPhotoRepository;
    private final ObjectMapper objectMapper;

    public void broadcastMatch(User self, User partner) {
        MatchEventPayload payloadForSelf = buildPayload(self, partner);
        MatchEventPayload payloadForPartner = buildPayload(partner, self);

        sendToUser(self.getUserId(), payloadForSelf);
        sendToUser(partner.getUserId(), payloadForPartner);
    }

    private void sendToUser(String userId, MatchEventPayload payload) {
        messagingTemplate.convertAndSend("/topic/matches/" + userId, payload);
    }

    private MatchEventPayload buildPayload(User self, User partner) {
        return MatchEventPayload.builder()
                .selfUserId(self.getUserId())
                .selfName(self.getNickname())
                .selfAvatarUrl(primaryPhoto(self.getUserId()))
                .partnerUserId(partner.getUserId())
                .partnerName(partner.getNickname())
                .partnerAvatarUrl(primaryPhoto(partner.getUserId()))
                .matchedAt(Instant.now().toString())
                .build();
    }

    private String primaryPhoto(String userId) {
        try {
            String jsonString = userPhotoRepository.findAttributesJsonByUser_UserId(userId);
            if (jsonString == null || jsonString.isEmpty()) {
                return null;
            }
            PhotoDTO photoDTO = objectMapper.readValue(jsonString, PhotoDTO.class);
            List<String> urls = photoDTO.getUrls() == null ? Collections.emptyList() : photoDTO.getUrls();
            return urls.isEmpty() ? null : urls.getFirst();
        } catch (Exception e) {
            System.out.println("[MatchSocket] Failed to parse photo for " + userId + " : " + e.getMessage());
            return null;
        }
    }
}
