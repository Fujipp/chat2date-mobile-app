package sit.chat2date.cp25ssi2.services;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.dto.MatchDTO;
import sit.chat2date.cp25ssi2.dto.MatchListResponse;
import sit.chat2date.cp25ssi2.dto.PhotoDTO;
import sit.chat2date.cp25ssi2.entities.Match;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.exceptions.BadRequestException;
import sit.chat2date.cp25ssi2.exceptions.ForbiddenAccessException;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.repositories.MatchRepository;
import sit.chat2date.cp25ssi2.repositories.MessageRepository;
import sit.chat2date.cp25ssi2.repositories.UserPhotoRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final MatchRepository matchRepository;
    private final UserRepository userRepository;
    private final UserPhotoRepository userPhotoRepository;
    private final MessageRepository messageRepository;
    private final ObjectMapper objectMapper;

    /**
     * Get all matches for a user
     */
    public MatchListResponse getAllMatches(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));

        List<Match> matches = matchRepository.findAllByUser(user);

        List<MatchDTO> matchDTOs = matches.stream().map(match -> {
            User partner = match.getUserId1().getUserId().equals(userId)
                    ? match.getUserId2()
                    : match.getUserId1();

            if (partner.getDeleteFlag()) {
                return null;
            }

            Integer roomId = match.getId();
            boolean hasMessages = messageRepository.findFirstByRoomIdOrderByCreatedAtDesc(roomId).isPresent();
            String type = hasMessages ? "old" : "new";

            return MatchDTO.builder()
                    .matchId(String.valueOf(match.getId()))
                    .partnerId(partner.getUserId())
                    .partnerName(partner.getNickname())
                    .partnerImage(getFirstPhoto(partner.getUserId()))
                    .created(match.getCreatedAt())
                    .type(type)
                    .build();
        }).collect(Collectors.toList());

        return MatchListResponse.builder().matches(matchDTOs).build();
    }

    /**
     * Unmatch - delete the match
     */
    public void unmatch(String userId, String roomIdStr, String partnerId) {
        if (roomIdStr == null || roomIdStr.isBlank()) {
            throw new BadRequestException("roomId is required");
        }
        if (partnerId == null || partnerId.isBlank()) {
            throw new BadRequestException("partnerId is required");
        }

        Integer matchId = Integer.parseInt(roomIdStr);
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new NotFoundException("Match not found"));

        if (!match.getUserId1().getUserId().equals(userId) && !match.getUserId2().getUserId().equals(userId)) {
            throw new ForbiddenAccessException("Access denied to this match");
        }

        // Delete the match
        matchRepository.delete(match);
    }

    private String getFirstPhoto(String userId) {
        try {
            String jsonString = userPhotoRepository.findAttributesJsonByUser_UserId(userId);
            if (jsonString == null || jsonString.isEmpty()) {
                return null;
            }
            PhotoDTO photoDTO = objectMapper.readValue(jsonString, PhotoDTO.class);
            List<String> urls = photoDTO.getUrls() == null ? Collections.emptyList() : photoDTO.getUrls();
            return urls.isEmpty() ? null : urls.get(0);
        } catch (Exception e) {
            return null;
        }
    }
}
