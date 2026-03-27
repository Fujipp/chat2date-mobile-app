package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.dto.SosIncidentRequest;
import sit.chat2date.cp25ssi2.entities.*;
import sit.chat2date.cp25ssi2.enums.SosStatus;
import sit.chat2date.cp25ssi2.repositories.AppointmentRepository;
import sit.chat2date.cp25ssi2.repositories.EmergencyContactRepository;
import sit.chat2date.cp25ssi2.repositories.SosIncidentRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SosIncidentService {
    private final UserRepository userRepository;
    private final AppointmentRepository appointmentRepository;
    private final SosIncidentRepository sosIncidentRepository;
    private final EmergencyContactRepository emergencyContactRepository;

    public Integer createSosIncident(String userId, SosIncidentRequest req) {
        if (req.getAppointmentId() == null || req.getLatitude() == null || req.getLongitude() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "ข้อมูลไม่ครบถ้วน (appointmentId, latitude, longitude)");
        }

        if (req.getCalledNumber() == null || req.getCalledNumber().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "กรุณาระบุเบอร์โทรที่ติดต่อ (calledNumber)");
        }

        if (!req.getCalledNumber().matches("^0\\d{8,9}$")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "รูปแบบเบอร์โทรไม่ถูกต้อง (ต้องเป็นตัวเลข 9-10 หลัก และขึ้นต้นด้วย 0)");
        }

        User reporter = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ไม่พบผู้ใช้งานในระบบ"));

        Appointment appointment = appointmentRepository.findById(req.getAppointmentId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ไม่พบข้อมูลการนัดหมายนี้"));

        Match match = appointment.getMatch();
        User targetUser = null;

        String u1Id = match.getUserId1().getUserId();
        String u2Id = match.getUserId2().getUserId();

        if (userId.equals(u1Id)) {
            targetUser = match.getUserId2();
        } else if (userId.equals(u2Id)) {
            targetUser = match.getUserId1();
        } else {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "คุณไม่ได้อยู่ในนัดหมายนี้");
        }

        SosIncident incident = new SosIncident();
        incident.setAppointment(appointment);
        incident.setReporterId(reporter.getUserId());
        incident.setTargetUserId(targetUser.getUserId());
        incident.setLatitude(BigDecimal.valueOf(req.getLatitude()));
        incident.setLongitude(BigDecimal.valueOf(req.getLongitude()));
        incident.setCalledNumber(req.getCalledNumber());
        incident.setStatus(SosStatus.NEW);

        SosIncident savedIncident = sosIncidentRepository.save(incident);

        return savedIncident.getIncidentId();
    }

    public List<String> getEmergencyContacts(String userId) {
        List<EmergencyContact> contacts = emergencyContactRepository.findByUser_UserId(userId);

        return contacts.stream()
                .map(EmergencyContact::getTelephoneNumber)
                .toList();
    }

    @Transactional
    public void updateEmergencyContacts(String userId, List<String> phoneNumbers) {

        if (phoneNumbers == null || phoneNumbers.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "ต้องมีเบอร์โทรฉุกเฉินอย่างน้อย 1 เบอร์");
        }

        if (phoneNumbers.size() > 3) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "บันทึกเบอร์ฉุกเฉินได้สูงสุด 3 เบอร์เท่านั้น");
        }

        java.util.Set<String> uniquePhones = new java.util.HashSet<>();
        for (String phone : phoneNumbers) {
            if (phone != null && !phone.trim().isEmpty()) {
                String trimmedPhone = phone.trim();
                if (!trimmedPhone.matches("^0\\d{8,9}$")) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "รูปแบบเบอร์โทรไม่ถูกต้อง: " + trimmedPhone);
                }
                uniquePhones.add(trimmedPhone);
            }
        }

        emergencyContactRepository.deleteByUser_UserId(userId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ไม่พบผู้ใช้งาน"));

        for (String phone : uniquePhones) {
            EmergencyContact contact = new EmergencyContact();
            contact.setUser(user);
            contact.setTelephoneNumber(phone);
            emergencyContactRepository.save(contact);
        }
    }
}
