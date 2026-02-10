package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sit.chat2date.cp25ssi2.dto.ReportDetailResponse;
import sit.chat2date.cp25ssi2.entities.Report;
import sit.chat2date.cp25ssi2.enums.ReportStatus;
import sit.chat2date.cp25ssi2.services.AdminReportService;
import sit.chat2date.cp25ssi2.services.JwtTokenUtil;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    @Autowired
    JwtTokenUtil jwtTokenUtil;

    private final AdminReportService adminReportService;

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/request-refresh")
    public Map<String, Object> requestRefreshToken(@RequestBody Map<String, String> requestBody) {
        String identifier = requestBody.get("identifier");
        String jwtRefreshToken = jwtTokenUtil.generateRefreshToken(identifier);

        Map<String, Object> response = new HashMap<>();
        response.put("refreshToken", jwtRefreshToken);
        return response;
    }

    /**
     * GET /admin/reports - Get all reports with pagination and filtering
     */
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/reports")
    public ResponseEntity<Page<Report>> getAllReports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) ReportStatus status,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "DESC") String sortDirection) {

        Sort.Direction direction = sortDirection.equalsIgnoreCase("ASC") ? Sort.Direction.ASC : Sort.Direction.DESC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));

        Page<Report> reports = adminReportService.getAllReports(status, pageable);
        return ResponseEntity.ok(reports);
    }

    /**
     * GET /admin/reports/{id} - Get report details with evidence and user info
     */
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/reports/{id}")
    public ResponseEntity<ReportDetailResponse> getReportById(@PathVariable Integer id) {
        ReportDetailResponse report = adminReportService.getReportById(id);
        return ResponseEntity.ok(report);
    }

    /**
     * PUT /admin/reports/{id}/status - Update report status
     */
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/reports/{id}/status")
    public ResponseEntity<Report> updateReportStatus(
            @PathVariable Integer id,
            @RequestBody Map<String, String> body) {

        String statusStr = body.get("status");
        ReportStatus status = ReportStatus.valueOf(statusStr.toUpperCase());

        Report updatedReport = adminReportService.updateReportStatus(id, status);
        return ResponseEntity.ok(updatedReport);
    }
}
