package sit.chat2date.cp25ssi2.utils;

import org.springframework.stereotype.Component;

@Component
public class CardIdGenerator {

    public String generateTempCardId() {
        // Format: 000 + timestamp (9 หลัก) + random (1 หลัก) = 13 หลัก
        long timestamp = System.currentTimeMillis();
        String timestampStr = String.valueOf(timestamp);

        // เอา 9 หลักท้าย
        String last9 = timestampStr.substring(timestampStr.length() - 9);

        // เพิ่ม random 1 หลัก เพื่อป้องกัน collision
        int random = (int) (Math.random() * 10);

        return String.format("000%s%d", last9, random);
    }
}
