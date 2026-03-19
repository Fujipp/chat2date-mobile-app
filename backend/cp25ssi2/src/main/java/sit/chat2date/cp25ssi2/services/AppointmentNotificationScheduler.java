package sit.chat2date.cp25ssi2.services;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sit.chat2date.cp25ssi2.entities.Appointment;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.AppointmentStatus;
import sit.chat2date.cp25ssi2.repositories.AppointmentRepository;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class AppointmentNotificationScheduler {

    private final AppointmentRepository appointmentRepository;
    private final NotificationService notificationService;

    // Run every minute
    @Scheduled(cron = "0 * * * * *")
    @Transactional
    public void notifyForUpcomingAppointments() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime reminderTime = now.plusDays(1);
        LocalDateTime reminderWindowStart = reminderTime.minusMinutes(1);
        LocalDateTime reminderWindowEnd = reminderTime.plusMinutes(1);

        // Find appointments that are scheduled around 1 day from now and have not been reminded yet.
        List<Appointment> dueAppointments = appointmentRepository
                .findByStatusAndIsNotifiedFalseAndDateTimeBetween(
                        AppointmentStatus.SCHEDULED,
                        reminderWindowStart,
                        reminderWindowEnd);

        if (dueAppointments.isEmpty()) {
            return;
        }

        log.info("[Scheduler] Found {} appointments due for reminder notification", dueAppointments.size());

        for (Appointment appointment : dueAppointments) {
            try {
                User user1 = appointment.getMatch().getUserId1();
                User user2 = appointment.getMatch().getUserId2();
                String placeName = appointment.getPlace().getPlaceName();
                Integer roomId = appointment.getMatch().getId();

                // Send to User 1 (from User 2 context)
                notificationService.sendAppointmentReminderNotification(
                        user1.getUserId(),
                        user2.getNickname(),
                        roomId,
                        placeName
                );

                // Send to User 2 (from User 1 context)
                notificationService.sendAppointmentReminderNotification(
                        user2.getUserId(),
                        user1.getNickname(),
                        roomId,
                        placeName
                );

                // Mark as notified
                appointment.setIsNotified(true);
                appointmentRepository.save(appointment);

                log.info("[Scheduler] Sent reminder for appointment {}", appointment.getAppointmentId());
            } catch (Exception e) {
                log.error("[Scheduler] Error processing appointment {}: {}", appointment.getAppointmentId(), e.getMessage());
            }
        }
    }
}
