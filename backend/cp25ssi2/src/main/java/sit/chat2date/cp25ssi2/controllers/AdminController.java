package sit.chat2date.cp25ssi2.controllers;

import lombok.RequiredArgsConstructor;
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

import java.util.Map;

/**
 * REST controller for admin-only operations.
 * All endpoints require ADMIN role.
 */
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final JwtTokenUtil jwtTokenUtil;
    private final AdminReportService adminReportService;

    // ────────────────────────────────────────────────────────────────────────
    // Token
    // ────────────────────────────────────────────────────────────────────────

    /** POST /admin/request-refresh — Generate a new refresh token for a given identifier. */
    @PostMapping("/request-refresh")
    public Map<String, Object> generateRefreshToken(@RequestBody Map<String, String> requestBody) {
        String identifier = requestBody.get("identifier");
        String refreshToken = jwtTokenUtil.generateRefreshToken(identifier);
        return Map.of("refreshToken", refreshToken);
    }

    // ────────────────────────────────────────────────────────────────────────
    // Report Management
    // ────────────────────────────────────────────────────────────────────────

    /** GET /admin/reports — List all reports with pagination and optional status filter. */
    @GetMapping("/reports")
    public ResponseEntity<Page<Report>> getReports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) ReportStatus status,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "DESC") String sortDirection) {

        Sort.Direction direction = sortDirection.equalsIgnoreCase("ASC")
                ? Sort.Direction.ASC
                : Sort.Direction.DESC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(direction, sortBy));

        return ResponseEntity.ok(adminReportService.getAllReports(status, pageable));
    }

    /** GET /admin/reports/{id} — Get detailed report info including evidence and user data. */
    @GetMapping("/reports/{id}")
    public ResponseEntity<ReportDetailResponse> getReportDetail(@PathVariable Integer id) {
        return ResponseEntity.ok(adminReportService.getReportById(id));
    }

    /** PUT /admin/reports/{id}/status — Resolve or dismiss a report, optionally deducting behavior points. */
    @PutMapping("/reports/{id}/status")
    public ResponseEntity<Report> updateReportStatus(
            @PathVariable Integer id,
            @RequestBody Map<String, String> body) {

        ReportStatus newStatus = ReportStatus.valueOf(body.get("status").toUpperCase());
        int decreasePoint = body.containsKey("decreasePoint")
                ? Integer.parseInt(body.get("decreasePoint"))
                : 0;

        Report updated = adminReportService.updateReportStatus(id, newStatus, decreasePoint);
        return ResponseEntity.ok(updated);
    }
}
