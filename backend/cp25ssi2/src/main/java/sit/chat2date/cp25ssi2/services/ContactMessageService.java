package sit.chat2date.cp25ssi2.services;

import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.dto.ContactMessageRequest;
import sit.chat2date.cp25ssi2.dto.ContactMessageResponse;
import sit.chat2date.cp25ssi2.dto.ContactReplyRequest;
import sit.chat2date.cp25ssi2.entities.ContactMessage;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.ContactMessageStatus;
import sit.chat2date.cp25ssi2.repositories.ContactMessageRepository;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ContactMessageService {

    private final ContactMessageRepository contactMessageRepository;
    private final UserRepository userRepository;
    private final JavaMailSender mailSender;

    public Integer createContactMessage(String userId, ContactMessageRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ไม่พบผู้ใช้งานในระบบ"));

        String resolvedName = (req.getContactName() != null && !req.getContactName().isBlank())
                ? req.getContactName()
                : user.getFirstname() + " " + user.getLastname();

        if (req.getContactEmail() == null || req.getContactEmail().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "กรุณากรอกอีเมลสำหรับติดต่อกลับ");
        }

        ContactMessage contactMessage = ContactMessage.builder()
                .user(user)
                .contactName(resolvedName)
                .contactEmail(req.getContactEmail())
                .subject(req.getSubject())
                .message(req.getMessage())
                .status(ContactMessageStatus.NEW)
                .build();

        return contactMessageRepository.save(contactMessage).getContactId();
    }

    public List<ContactMessageResponse> getAllContactMessages() {
        return contactMessageRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(c -> ContactMessageResponse.builder()
                        .contactId(c.getContactId())
                        .userId(c.getUser().getUserId())
                        .contactName(c.getContactName())
                        .contactEmail(c.getContactEmail())
                        .subject(c.getSubject())
                        .message(c.getMessage())
                        .status(c.getStatus())
                        .repliedAt(c.getRepliedAt())
                        .createdAt(c.getCreatedAt())
                        .updatedAt(c.getUpdatedAt())
                        .build())
                .toList();
    }

    public void replyContactMessage(Integer contactId, ContactReplyRequest req) {
        ContactMessage contact = contactMessageRepository.findById(contactId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "ไม่พบข้อความนี้"));

        if (contact.getStatus() == ContactMessageStatus.RESOLVED) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "ข้อความนี้ถูกตอบกลับไปแล้ว");
        }


        try {
            MimeMessage mail = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mail, true, "UTF-8");
            helper.setFrom("support.chat2date@gmail.com");
            helper.setTo(contact.getContactEmail());
            helper.setSubject("Re: " + contact.getSubject());
            helper.setText(req.getReplyMessage(), false);
            mailSender.send(mail);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "ส่งเมลไม่สำเร็จ: " + e.getMessage());
        }


        contact.setStatus(ContactMessageStatus.RESOLVED);
        contact.setRepliedAt(LocalDateTime.now());
        contactMessageRepository.save(contact);
    }
}