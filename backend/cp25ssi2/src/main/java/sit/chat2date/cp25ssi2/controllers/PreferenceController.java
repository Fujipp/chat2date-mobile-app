package sit.chat2date.cp25ssi2.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import sit.chat2date.cp25ssi2.dto.PreferenceDto;
import sit.chat2date.cp25ssi2.services.PreferenceService;


@RestController
public class PreferenceController {
    @Autowired
    private PreferenceService preferenceService;

    @GetMapping("/preferences")
    public PreferenceDto getAllPreferences() {
        return preferenceService.allPreferece();
    }

}
