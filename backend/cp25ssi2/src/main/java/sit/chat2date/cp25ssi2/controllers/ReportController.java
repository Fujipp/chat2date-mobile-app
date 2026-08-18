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
import sit.chat2date.cp25ssi2.exceptions.UnauthorizedAccessException;
import sit.chat2date.cp25ssi2.services.ReportService;

import java.util.List;
import java.util.Optional;

/**
 * REST controller for user reports.
 * Allows users to report inappropriate behavior with optional evidence files.
 */
@RestController
@RequestMapping("/report")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    /** POST /report — Submit a new report with optional evidence images. Returns 201 Created. */
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ReportResponse> submitReport(
            @AuthenticationPrincipal Optional<User> userOpt,
            @RequestPart("data") ReportRequest request,
            @RequestPart(value = "evidence", required = false) List<MultipartFile> evidenceFiles) {
        User user = userOpt.orElseThrow(() -> new UnauthorizedAccessException("User not found"));
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(reportService.createReport(user.getUserId(), request, evidenceFiles));
    }
}
