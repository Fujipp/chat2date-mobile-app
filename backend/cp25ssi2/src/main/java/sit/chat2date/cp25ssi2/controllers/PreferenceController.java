package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import sit.chat2date.cp25ssi2.dto.PreferenceDTO;
import sit.chat2date.cp25ssi2.services.PreferenceService;

@RestController
@RequiredArgsConstructor
public class PreferenceController {

    private final PreferenceService preferenceService;

    @GetMapping("/preferences")
    public PreferenceDTO getAllPreferences() {
        return preferenceService.allPreferece();
    }

}
