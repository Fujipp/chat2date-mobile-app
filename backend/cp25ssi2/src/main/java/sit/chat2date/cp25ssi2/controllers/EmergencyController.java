package sit.chat2date.cp25ssi2.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import sit.chat2date.cp25ssi2.services.SosIncidentService;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/users")
public class EmergencyController {

    @Autowired
    private SosIncidentService sosIncidentService;

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
            @RequestBody sit.chat2date.cp25ssi2.dto.EmergencyCallRequest req) {

        sosIncidentService.updateEmergencyContacts(userId, req.getPhoneNumbers());

        return ResponseEntity.ok(Map.of(
                "message", "อัปเดตเบอร์โทรฉุกเฉินเรียบร้อยแล้ว"
        ));
    }
}
