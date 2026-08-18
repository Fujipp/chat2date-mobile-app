package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.EmergencyCallRequest;
import sit.chat2date.cp25ssi2.services.SosIncidentService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class EmergencyController {

    private final SosIncidentService sosIncidentService;

    @GetMapping("/emergency-calls")
    public ResponseEntity<?> getEmergencyCall(
            @RequestAttribute("userId") String userId) {
        List<String> phoneNumbers = sosIncidentService.getEmergencyContacts(userId);
        return ResponseEntity.ok(Map.of(
                "phoneNumber", phoneNumbers
        ));
    }

    @PutMapping("/emergency-calls")
    public ResponseEntity<?> updateEmergencyCalls(
            @RequestAttribute("userId") String userId,
            @RequestBody EmergencyCallRequest req) {

        sosIncidentService.updateEmergencyContacts(userId, req.getPhoneNumbers());

        return ResponseEntity.ok(Map.of(
                "message", "อัปเดตเบอร์โทรฉุกเฉินเรียบร้อยแล้ว"
        ));
    }
}
