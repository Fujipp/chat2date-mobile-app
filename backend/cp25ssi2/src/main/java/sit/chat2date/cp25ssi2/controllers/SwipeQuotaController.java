package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.SwipeQuotaResponse;
import sit.chat2date.cp25ssi2.entities.SwipeQuota;
import sit.chat2date.cp25ssi2.repositories.SwipeQuotaRepository;
import sit.chat2date.cp25ssi2.services.SwipeQuotaService;

@RestController
@RequestMapping("/swipe")
@RequiredArgsConstructor
public class SwipeQuotaController {

    @Autowired
    private SwipeQuotaService swipeQuotaService;

    @GetMapping("/check-status")
    public ResponseEntity<SwipeQuotaResponse> checkStatus(@RequestHeader("Authorization") String accessToken) {
        return ResponseEntity.ok(swipeQuotaService.getQuotaStatus(accessToken));
    }

    @PutMapping("/process")
    public ResponseEntity<SwipeQuotaResponse> processSwipe(@RequestHeader("Authorization") String accessToken) {
        SwipeQuotaResponse response = swipeQuotaService.processSwipe(accessToken);
        return ResponseEntity.ok(response);
    }
}
