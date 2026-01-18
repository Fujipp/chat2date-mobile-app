package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import sit.chat2date.cp25ssi2.dto.ReportRequest;
import sit.chat2date.cp25ssi2.dto.ReportResponse;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.services.ReportService;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/report")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    /**
     * POST /api/v1/report - Create a new report with optional evidence files
     */
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ReportResponse> createReport(
            @AuthenticationPrincipal Optional<User> userOpt,
            @RequestPart("data") ReportRequest request,
            @RequestPart(value = "evidence", required = false) List<MultipartFile> evidenceFiles) {
        User user = userOpt.orElseThrow(() -> new RuntimeException("User not found"));
        ReportResponse response = reportService.createReport(user.getUserId(), request, evidenceFiles);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
