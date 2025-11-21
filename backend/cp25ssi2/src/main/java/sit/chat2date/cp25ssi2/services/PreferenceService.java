package sit.chat2date.cp25ssi2.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import sit.chat2date.cp25ssi2.dto.PreferenceDTO;
import sit.chat2date.cp25ssi2.entities.Interest;
import sit.chat2date.cp25ssi2.entities.LifeStyle;
import sit.chat2date.cp25ssi2.entities.Tag;
import sit.chat2date.cp25ssi2.entities.TravelStyle;
import sit.chat2date.cp25ssi2.repositories.*;

import java.util.Comparator;

@Service
public class PreferenceService {

    @Autowired
    private TravelStyleRepository travelStyleRepository;
    @Autowired
    private LifeStyleRepository lifeStyleRepository;
    @Autowired
    private TagRepository tagRepository;
    @Autowired
    private InterestRepository interestRepository;

    public PreferenceDTO allPreferece() {
        return PreferenceDTO.builder().
                interests(interestRepository.findAll().stream()
                        .sorted(Comparator.comparing(Interest::getId))
                        .toList()).
                tags(tagRepository.findAll().stream()
                        .sorted(Comparator.comparing(Tag::getId))
                        .toList()).
                lifeStyles(lifeStyleRepository.findAll().stream()
                        .sorted(Comparator.comparing(LifeStyle::getId))
                        .toList()).
                travelStyles(travelStyleRepository.findAll().stream()
                        .sorted(Comparator.comparing(TravelStyle::getId))
                        .toList()).
                build();
    }
}
