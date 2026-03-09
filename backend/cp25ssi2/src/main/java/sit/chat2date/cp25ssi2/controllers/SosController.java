package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.SosIncidentRequest;
import sit.chat2date.cp25ssi2.services.SosIncidentService;

import java.util.Map;

@RestController
@RequestMapping("/sos")
@RequiredArgsConstructor
public class SosController {

    private final SosIncidentService sosIncidentService;

    @PostMapping("/incidents")
    public ResponseEntity<?> triggerSos(
            @RequestAttribute("userId") String userId,
            @RequestBody SosIncidentRequest req) {

        Integer incidentId = sosIncidentService.createSosIncident(userId, req);

        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of(
                "incidentId", incidentId,
                "message", "ส่งข้อมูลแจ้งเตือนไปยังผู้ดูแลระบบเรียบร้อยแล้ว"
        ));
    }
}