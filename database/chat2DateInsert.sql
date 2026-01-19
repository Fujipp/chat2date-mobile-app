-- 
-- 1.
-- USE `chat2date` SCHEMA
-- 
USE `chat2date`;

-- 
-- 2.
-- INSERT DATA INTO LOOKUP TABLES (Independent Data)
-- (interest, lifestyle, tag, travelstyle)
-- 
INSERT IGNORE INTO `interest` (`interest`) VALUES
-- 🌍 การท่องเที่ยว
('ทะเลและเกาะ'),
('ภูเขาและเดินป่า'),
('เที่ยวตามเมือง'),
('แหล่งท่องเที่ยวทางวัฒนธรรม'),
('ท่องเที่ยวเชิงอาหาร'),
('ท่องเที่ยวผจญภัย'),
('เป้เดินทาง (Backpacking)'),
('ท่องเที่ยวหรูหรา'),
('ขับรถเที่ยว'),
('เที่ยวสุดสัปดาห์'),
('เที่ยวต่างประเทศ'),
('เที่ยวในประเทศ'),
('แคมป์ปิ้ง'),
('เที่ยวคนเดียว'),
('เที่ยวกลุ่ม'),

-- 🎵 ดนตรี
('เพลงป๊อป'),
('เพลงร็อค/อินดี้'),
('ฮิปฮอป/แร็พ'),
('อาร์แอนด์บี/โซล'),
('EDM/อิเล็กทรอนิกส์'),
('แจ๊ส/บลูส์'),
('ดนตรีคลาสสิก'),
('เพลงไทย (ลูกทุ่ง/ลูกกรุง)'),
('เคป๊อป'),
('เจป๊อป'),
('ทีป๊อป'),
('คอนเสิร์ต/เทศกาลดนตรี'),
('ดนตรีสด'),
('เล่นดนตรี'),
('ร้องเพลง/คาราโอเกะ'),


-- 💪 ออกกำลังกาย
('ยกน้ำหนัก'),
('คาร์ดิโอ'),
('โยคะ'),
('พิลาทิส'),
('วิ่ง'),
('ปั่นจักรยาน'),
('ว่ายน้ำ'),
('มวย/มวยไทย'),
('ศิลปะการต่อสู้'),
('เต้นแอโรบิก/ซุมบ้า'),
('ออกกำลังกายที่บ้าน'),
('เพาะกาย'),

-- ⚽ กีฬา
('ฟุตบอล'),
('บาสเกตบอล'),
('วอลเลย์บอล'),
('แบดมินตัน'),
('เทนนิส'),
('กอล์ฟ'),
('เบสบอล'),
('รักบี้'),
('ฟอร์มูล่าวัน/รถแข่ง'),
('อีสปอร์ต'),
('ดูกีฬา'),
('กีฬาเอ็กซ์ตรีม'),

-- 🎬 ภาพยนตร์และซีรีส์
('หนังแอ็คชั่น'),
('หนังตลก'),
('หนังดราม่า'),
('หนังสยองขวัญ/ระทึกขวัญ'),
('หนังรัก/โรแมนติก'),
('หนังไซไฟ/แฟนตาซี'),
('สารคดี'),
('หนังการ์ตูน/แอนิเมชั่น'),
('หนังไทย'),
('ซีรีส์เกาหลี'),
('Netflix & Chill'),
('ไปดูหนังโรงภาพยนตร์'),

-- 🎨 ศิลปะและความคิดสร้างสรรค์
('วาดภาพ/เขียนภาพ'),
('ถ่ายภาพ'),
('ศิลปะดิจิทัล'),
('กราฟิกดีไซน์'),
('งานฝีมือ/DIY'),
('เขียนหนังสือ/บทกวี'),
('พิพิธภัณฑ์/หอศิลป์'),
('สตรีทอาร์ต'),
('ออกแบบแฟชั่น'),
('ออกแบบตกแต่งภายใน'),
('สถาปัตยกรรม'),

-- 🎮 เกมและเทคโนโลยี
('เล่นเกมคอนโซล'),
('เล่นเกมพีซี'),
('เล่นเกมมือถือ'),
('เกม RPG'),
('เกม FPS'),
('เกมกลยุทธ์'),
('เกมกีฬา'),
('บอร์ดเกม'),
('เกมไพ่'),
('VR Gaming'),
('พัฒนาเกม'),
('เทคโนโลยี/แก็ดเจ็ต'),
('เขียนโปรแกรม'),
('AI/นวัตกรรม'),

-- ☕ อาหารและเครื่องดื่ม
('คอกาแฟ'),
('คอชา'),
('ทำอาหาร'),
('ทำขนม/เบเกอรี่'),
('อาหารริมทาง'),
('ร้านอาหารหรู'),
('อาหารไทย'),
('อาหารญี่ปุ่น'),
('อาหารเกาหลี'),
('อาหารอิตาเลียน'),
('อาหารจีน'),
('มังสวิรัติ/วีแกน'),
('ของหวาน/ขนม'),

-- 🌳 กิจกรรมกลางแจ้งและธรรมชาติ
('เดินป่า/ปีนเขา'),
('แคมป์ปิ้ง'),
('ปีนหน้าผา'),
('พายเรือคายัค'),
('โต้คลื่น/เล่นกระดาน'),
('ดำน้ำลึก'),
('ดำน้ำตื้น'),
('ตกปลา'),
('ดูนก'),
('ถ่ายภาพสัตว์ป่า'),
('อุทยานแห่งชาติ'),
('กิจกรรมชายหาด'),
('ปิกนิก'),
('ดูดาว'),
('ทำสวน/ปลูกต้นไม้'),

-- 🚶 การเดินและไลฟ์สไตล์
('เดินเล่น/จ็อกกิ้ง'),
('เดินเช้า'),
('เดินเย็น'),
('ไปสวนสาธารณะ'),
('ช้อปปิ้งดูของ'),
('สำรวจเมือง'),
('เดินตลาด'),
('เดินในธรรมชาติ'),
('พาสุนัขเดินเล่น'),
('เดินถ่ายภาพ'),

-- 🎉 ไนท์ไลฟ์และสังคม
('บาร์/ผับ'),
('คลับ/เต้นรำ'),
('รูฟท็อปบาร์'),
('ฟังเพลงสด'),
('คาราโอเกะ'),
('ตลาดกลางคืน'),
('กินข้าวดึก'),
('ล่าบาร์'),
('ค็อกเทลบาร์'),
('เทศกาลดนตรี'),

-- 🛍️ ช้อปปิ้งและแฟชั่น
('แฟชั่น/สไตล์'),
('สตรีทแวร์'),
('แบรนด์เนม'),
('ของวินเทจ'),
('ช้อปออนไลน์'),
('ช้อปห้าง'),
('ช้อปตลาด'),
('รองเท้าสนีกเกอร์'),
('เครื่องประดับ'),
('ความงาม/ดูแลผิว'),

-- 💼 การงานและพัฒนาตนเอง
('ทำธุรกิจ/ผู้ประกอบการ'),
('สตาร์ทอัพ'),
('การลงทุน'),
('พัฒนาตนเอง'),
('พูดในที่สาธารณะ'),
('สร้างเครือข่าย'),
('รายได้เสริม'),
('พัฒนาอาชีพ'),
('ความเป็นผู้นำ'),

-- 🌟 อาสาสมัครและกิจกรรมเพื่อสังคม
('ทำงานการกุศล'),
('รักษ์สิ่งแวดล้อม'),
('บริการชุมชน'),

-- 🎓 ภาษาและการศึกษา
('เรียนภาษาใหม่'),
('ภาษาอังกฤษ'),
('ภาษาจีน'),
('ภาษาญี่ปุ่น'),
('ภาษาเกาหลี'),
('แลกเปลี่ยนภาษา');


INSERT IGNORE INTO `lifestyle` (`lifeStyle`) VALUES
-- 🌟 ราศี
('ราศีมังกร'),
('ราศีกุมภ์'),
('ราศีมีน'),
('ราศีเมษ'),
('ราศีพฤษภ'),
('ราศีเมถุน'),
('ราศีกรกฎ'),
('ราศีสิงห์'),
('ราศีกันย์'),
('ราศีตุลย์'),
('ราศีพิจิก'),
('ราศีธนู'),

-- 🎓 การศึกษา
('ปริญญาตรี'),
('กำลังเรียนมหาวิทยาลัย'),
('มัธยมปลาย'),
('ปริญญาเอก'),
('กำลังเรียนต่อ'),
('ปริญญาโท'),
('วิทยาลัยการอาชีพ'),

-- 👶 แผนการมีครอบครัว
('ฉันอยากมีลูก'),
('ฉันไม่อยากมีลูก'),
('ฉันมีลูก และอยากมีเพิ่มอีก'),
('ฉันมีลูก แต่ไม่อยากมีเพิ่มอีก'),
('ยังไม่แน่ใจ'),

-- 💬 สไตล์การสื่อสาร
('คนชอบแชท'),
('คุยโทรศัพท์'),
('ชอบวิดีโอคอล'),
('คนไม่ค่อยแชท'),
('เจอหน้ากันดีกว่า'),

-- 💖 การแสดงความรัก
('การกระทำที่เอาใจใส่'),
('ของขวัญ'),
('การสัมผัส'),
('คำชม'),
('การใช้เวลาร่วมกัน'),

-- 🐾 สัตว์เลี้ยง
('หมา'),
('แมว'),
('สัตว์เลื้อยคลาน'),
('สัตว์ครึ่งบกครึ่งน้ำ'),
('นก'),
('ปลา'),
('ไม่มี แต่รักสัตว์นะ'),
('อื่นๆ'),
('เต่า'),
('หนูแฮมสเตอร์'),
('กระต่าย'),
('ไม่เลี้ยงสัตว์'),
('สัตว์เลี้ยงทุกชนิด'),
('อยากมีสัตว์เลี้ยง'),
('ภูมิแพ้สัตว์เลี้ยง'),

-- 🍺 ดื่มเหล้า
('ไม่ใช่ทางอ่ะ'),
('ไม่ดื่มเหล้า'),
('เลือกที่จะไม่ดื่มดีกว่า'),
('ดื่มบ้างตามโอกาสพิเศษ'),
('ดื่มสังสรรค์ช่วงวันหยุด'),
('แทบทุกคืน'),

-- 🚬 สูบบุหรี่บ่อยแค่ไหน
('สูบบุหรี่เข้าสังคม'),
('สูบบุหรี่เฉพาะตอนกินเหล้า'),
('ไม่สูบบุหรี่'),
('นักสูบ'),
('พยายามเลิกอยู่'),

-- 🍃 กัญชา
('ใช่'),
('เป็นครั้งคราว'),
('เวลาเข้าสังคมก็มีบ้าง'),
('ไม่เคย'),

-- 🏃 ออกกำลังกาย
('ทุกวัน'),
('ค่อนข้างบ่อย'),
('เป็นบางครั้ง'),
('ไม่เคย'),

-- 🍽 ตัวเลือกอาหารที่กินได้
('วีแกน'),
('กินมังสวิรัติ'),
('กินแต่อาหารทะเล'),
('โคเชอร์'),
('ฮาลาล'),
('กินเนื้อสัตว์'),
('กินเนื้อสัตว์และผัก'),
('อื่นๆ'),

-- 📱 โซเชียลมีเดีย
('เน็ตไอดอล'),
('เล่นโซเชียลประจำ'),
('ไม่เล่นเลย'),
('ไถฟีดไปเรื่อย'),

-- 😴 รูทีนการนอน
('คนตื่นเช้า'),
('สายนอนดึก'),
('กลางๆ ไม่นอนดึก ไม่ตื่นเช้า');


INSERT IGNORE INTO `tag` (`tag`) VALUES
-- 💫 บุคลิก & สไตล์ชีวิต
('อินโทรเวิร์ต'),
('เอ็กซ์โทรเวิร์ต'),
('สายชิล'),
('สายลุย'),
('สายฮา'),
('สายเปย์'),
('สายหวาน'),
('สายติสท์'),
('ชอบอยู่บ้าน'),
('ชอบออกนอกบ้าน'),
('คนอบอุ่น'),
('คนจริงจัง'),
('สายมู'),
('สายเกา'),
('สายฝอ'),
('ชอบคอนเทนต์'),
('ติ่งซีรีส์'),
('คนโลกส่วนตัวสูง'),

-- ☕ ไลฟ์สไตล์ & งานอดิเรก
('สายคาเฟ่'),
('หนอนหนังสือ'),
('คอซีรีส์'),
('คอหนัง'),
('คอเกม'),
('ชอบทำอาหาร'),
('สายออกกำลังกาย'),
('นักวิ่ง'),
('นักเดินป่า'),
('ชอบเที่ยว'),
('สายแคมป์'),
('รักทะเล'),
('ชอบถ่ายรูป'),
('ชอบแต่งตัว'),
('นักสะสม'),
('ชอบฟังเพลง'),
('เล่นดนตรี'),
('ชอบเต้น'),
('ชอบ DIY'),
('ชอบดูดวง'),

-- 🐶 สัตว์เลี้ยง & ธรรมชาติ
('ทาสหมา'),
('ทาสแมว'),
('รักสัตว์'),
('คนแพ้ขนสัตว์'),
('ชอบปลูกต้นไม้'),
('คนรักษ์โลก'),
('รักธรรมชาติ'),
('นักปลูกต้นไม้'),

-- 🍔 อาหาร & เครื่องดื่ม
('สายหวาน'),
('สายเนื้อ'),
('วีแกน'),
('ชอบกาแฟ'),
('สายนมไข่มุก'),
('ชอบชาบู'),
('ชอบปิ้งย่าง'),
('ชอบทำขนม'),
('ชอบอาหารญี่ปุ่น'),
('ชอบอาหารเกาหลี'),
('ชอบกินเล่น'),

-- 🌍 ความคิด & ค่านิยม
('สายมูเตลู'),
('สายฮีล'),
('สายธรรมะ'),
('รักอิสระ'),
('รักครอบครัว'),
('รักเดียวใจเดียว'),
('เปิดใจ'),
('ชอบพูดตรง'),
('ไม่ชอบดราม่า'),
('สายบวก'),

-- 💻 ดิจิทัล & เทรนด์
('สายโซเชียล'),
('TikToker'),
('ชอบถ่ายคลิป'),
('ชอบทำคอนเทนต์'),
('เกมเมอร์'),
('ชอบเทคโนโลยี'),
('ชอบ AI'),
('ชอบรีวิวของ'),

-- 🧠 MBTI Personality Types
('INTJ'),
('INTP'),
('ENTJ'),
('ENTP'),
('INFJ'),
('INFP'),
('ENFJ'),
('ENFP'),
('ISTJ'),
('ISFJ'),
('ESTJ'),
('ESFJ'),
('ISTP'),
('ISFP'),
('ESTP'),
('ESFP');


INSERT INTO `travelstyle` (`travelStyle`) VALUES
('สายลุยผจญภัย'),
('เที่ยวในเมือง'),
('เที่ยวธรรมชาติ'),
('สายวัฒนธรรม'),
('สายกินเที่ยว');

-- 
-- 3.
-- INSERT 2 USERS
-- 
INSERT INTO `user` 
(`userId`, `email`, `phoneNumber`, `provider`, `firstname`, `lastname`, `nickname`, `cardId`, `birthday`, `sex`, `behaviorScore`, `isBlacklist`, `accountStatus`, `version`, `role`) 
VALUES
(1, 'user1@example.com', '0810000001', 'GOOGLE', 'สมชาย', 'ใจดี', 'ชาย', '1100000000001', '1995-03-15', 'MALE', 0, 0, 'ACTIVE', 1, 'USER'),
(2, 'user2@example.com', '0820000002', 'OTP', 'สมหญิง', 'รักสงบ', 'หญิง', '1200000000002', '1998-08-20', 'FEMALE', 0, 0, 'ACTIVE', 1, 'USER');

-- 
-- 4.
-- INSERT 1-to-1 and 1-to-Many TABLES (Dependent on Users)
-- 
-- Emergency Contacts
INSERT INTO `emergencycontact` (`telephoneNumber`, `userId`) VALUES
('0911111111', 1),
('0922222222', 2);

-- Preference Match (1-to-1 relation)
INSERT INTO `preferencematch` (`interestedGender`, `interestedTravelStyle`, `interestedLifeStyle`, `interestedInterest`, `interestedAgeMin`, `interestedAgeMax`, `interestedDistanceMin`, `interestedDistanceMax`, `userId`) VALUES
('UNRELATED', 'SAME', 'NEARLY', 'NEARLY', 25, 35, 0, 50, 1),
('UNRELATED', 'NEARLY', 'SAME', 'NEARLY', 28, 40, 0, 100, 2);

-- Temp User Location (1-to-1 relation)
INSERT INTO `tempuserlocation` (`latitude`, `longtitude`, `accuracy`, `timestamp`, `userId`) VALUES
(13.76300000, 99.58000000, 50.00, NOW(), 1), -- Bangkok (แก้ longitude < 100)
(18.78800000, 98.98300000, 50.00, NOW(), 2); -- Chiang Mai


-- User Photos (1-to-Many relation)
INSERT INTO `userphoto` (`userId`, `attributes`) VALUES
(1, '{"url": "https://example.com/photos/user1_profile.jpg", "isProfile": true, "order": 1}'),
(1, '{"url": "https://example.com/photos/user1_gallery1.jpg", "isProfile": false, "order": 2}'),
(2, '{"url": "https://example.com/photos/user2_profile.jpg", "isProfile": true, "order": 1}'),
(2, '{"url": "https://example.com/photos/user2_gallery1.jpg", "isProfile": false, "order": 2}'),
(2, '{"url": "https://example.com/photos/user2_gallery2.jpg", "isProfile": false, "order": 3}');

-- 
-- 5.
-- INSERT Many-to-Many LINKING TABLES
-- 
-- User 1: 'ดนตรี', 'เขียนโค้ด'
-- User 2: 'ท่องเที่ยว', 'ทำอาหาร'
INSERT INTO `user_has_interest` (`user_userId`, `interest_interestId`) VALUES
(1, 1),
(1, 3),
(2, 2),
(2, 4);

-- User 1: 'คนนอนดึก'
-- User 2: 'คนตื่นเช้า'
INSERT INTO `user_has_lifestyle` (`user_userId`, `lifestyle_lifestyleId`) VALUES
(1, 2),
(2, 1);

-- User 1: 'รักกาแฟ', 'ทาสแมว'
-- User 2: 'ทาสหมา', 'เกมเมอร์'
INSERT INTO `user_has_tag` (`user_userId`, `tag_tagId`) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 6);

-- User 1: 'สายลุยผจญภัย'
-- User 2: 'เที่ยวชิลๆ'
INSERT INTO `user_has_travelstyle` (`user_userId`, `travelstyle_travelId`) VALUES
(1, 3),
(2, 4);

-- 
-- 6.
-- INSERT INTERACTION TABLES
-- 
-- User 1 likes User 2
-- User 2 likes User 1
-- (This creates a mutual match)
INSERT INTO `action` (`userId`, `actionType`, `targetUserId`) VALUES
(1, 'LIKE', 2),
(2, 'LIKE', 1);

-- Match record for User 1 and User 2
INSERT INTO `match` (`userId1`, `userId2`) VALUES
(1, 2);

--
-- 7.
-- CHAT / REPORT TEST DATA
--
SET @chat_user1 := 'b6f0f0d2-2f1d-4b0d-9a10-8f2f1b8d9a11';
SET @chat_user2 := 'a7c2c3d4-5e6f-4712-8a9b-0c1d2e3f4a5b';
SET @report_target := 'c9a1b2c3-d4e5-4f67-8901-23456789abcd';

INSERT IGNORE INTO `user`
(`userId`, `email`, `phoneNumber`, `provider`, `firstname`, `lastname`, `nickname`, `cardId`, `birthday`, `sex`, `behaviorScore`, `isBlacklist`, `accountStatus`, `version`, `role`)
VALUES
(@chat_user1, 'seed.chat1@example.com', '0890000011', 'GOOGLE', 'Seed', 'One', 'SeedOne', '9900000000011', '1997-01-15', 'MALE', 0, 0, 'ACTIVE', 1, 'USER'),
(@chat_user2, 'seed.chat2@example.com', '0890000022', 'GOOGLE', 'Seed', 'Two', 'SeedTwo', '9900000000022', '1998-02-20', 'FEMALE', 0, 0, 'ACTIVE', 1, 'USER'),
(@report_target, 'seed.report@example.com', '0890000033', 'GOOGLE', 'Seed', 'Report', 'SeedReport', '9900000000033', '1996-06-30', 'FEMALE', 0, 0, 'ACTIVE', 1, 'USER');

INSERT INTO `userphoto` (`userId`, `attributes`) VALUES
(@chat_user1, '{\"urls\":[\"https://example.com/photos/seed1_1.jpg\",\"https://example.com/photos/seed1_2.jpg\"]}'),
(@chat_user2, '{\"urls\":[\"https://example.com/photos/seed2_1.jpg\",\"https://example.com/photos/seed2_2.jpg\"]}');

INSERT INTO `match` (`userId1`, `userId2`)
SELECT @chat_user1, @chat_user2
WHERE NOT EXISTS (
  SELECT 1 FROM `match`
  WHERE (`userId1` = @chat_user1 AND `userId2` = @chat_user2)
     OR (`userId1` = @chat_user2 AND `userId2` = @chat_user1)
);
SET @roomId := (
  SELECT `matchId` FROM `match`
  WHERE (`userId1` = @chat_user1 AND `userId2` = @chat_user2)
     OR (`userId1` = @chat_user2 AND `userId2` = @chat_user1)
  ORDER BY `matchId` DESC
  LIMIT 1
);

INSERT IGNORE INTO `relationship_stats`
(`relationshipId`, `score`, `streakDays`, `isFirstMessageBonus`, `dailyMessageCount`, `dailyDate`)
VALUES
(@roomId, 85, 3, TRUE, 5, CURRENT_DATE);

INSERT INTO `messages` (`roomId`, `senderId`, `message`, `messageType`, `isRead`, `createdAt`) VALUES
(@roomId, @chat_user1, 'Hi SeedTwo, this is SeedOne.', 'TEXT', TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(@roomId, @chat_user2, 'Hello SeedOne! nice to meet you.', 'TEXT', FALSE, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(@roomId, @chat_user1, 'Ready for a game?', 'GAME', TRUE, DATE_SUB(NOW(), INTERVAL 12 HOUR));

INSERT INTO `chat_access_logs` (`userId`, `roomId`, `actionType`, `createdAt`) VALUES
(@chat_user1, @roomId, 'ENTER', DATE_SUB(NOW(), INTERVAL 5 MINUTE)),
(@chat_user2, @roomId, 'EXIT', DATE_SUB(NOW(), INTERVAL 2 MINUTE));

INSERT INTO `game_sessions` (`gameId`, `roomId`, `totalScore`, `status`) VALUES
('game_seed_1', @roomId, 7, 'ACTIVE')
ON DUPLICATE KEY UPDATE
`totalScore` = VALUES(`totalScore`),
`status` = VALUES(`status`);

INSERT INTO `game_questions` (`questionId`, `gameId`, `question`, `options`, `correctAnswer`, `userSelectedOption`, `isCorrect`) VALUES
('q_seed_1', 'game_seed_1', 'Which place would you prefer for a first date?', '[\"Cafe\",\"Park\",\"Museum\",\"Beach\"]', 'Cafe', 'Park', FALSE)
ON DUPLICATE KEY UPDATE
`userSelectedOption` = VALUES(`userSelectedOption`),
`isCorrect` = VALUES(`isCorrect`);

INSERT INTO `reports` (`reporterId`, `targetUserId`, `reason`, `anotherReason`, `description`, `status`, `isNotified`)
SELECT @chat_user1, @report_target, 'spam', NULL, 'Test report for spam messages', 'PENDING', FALSE
WHERE NOT EXISTS (
  SELECT 1 FROM `reports`
  WHERE `reporterId` = @chat_user1 AND `targetUserId` = @report_target
);
SET @reportId := (
  SELECT `reportId` FROM `reports`
  WHERE `reporterId` = @chat_user1 AND `targetUserId` = @report_target
  ORDER BY `reportId` DESC
  LIMIT 1
);

INSERT INTO `report_evidences` (`reportId`, `evidenceUrl`)
SELECT @reportId, '[\"https://example.com/evidence/seed-report-1.jpg\"]'
WHERE NOT EXISTS (
  SELECT 1 FROM `report_evidences` WHERE `reportId` = @reportId
);

--
-- 8.
-- MORE CHAT TEST DATA (OTP USERS)
--
SET @otp_user1 := '4f1c8b6a-2f0b-4b3f-9a2c-1b2c3d4e5f01';
SET @otp_user2 := '7a3d9c1b-5e2a-4f7b-8c1d-2e3f4a5b6c02';
SET @otp_user3 := '9b5e1d2c-7f3a-4c8b-9d2e-3f4a5b6c7d03';
SET @otp_user4 := '1c6f2e3d-8a4b-5d9c-0e3f-4a5b6c7d8e04';

INSERT IGNORE INTO `user`
(`userId`, `email`, `phoneNumber`, `provider`, `firstname`, `lastname`, `nickname`, `cardId`, `birthday`, `sex`, `behaviorScore`, `isBlacklist`, `accountStatus`, `version`, `role`)
VALUES
(@otp_user1, NULL, '0890000101', 'OTP', 'Otp', 'One', 'OtpOne', '9900000000101', '1999-01-10', 'MALE', 0, 0, 'ACTIVE', 1, 'USER'),
(@otp_user2, NULL, '0890000102', 'OTP', 'Otp', 'Two', 'OtpTwo', '9900000000102', '1998-02-11', 'FEMALE', 0, 0, 'ACTIVE', 1, 'USER'),
(@otp_user3, NULL, '0890000103', 'OTP', 'Otp', 'Three', 'OtpThree', '9900000000103', '1997-03-12', 'FEMALE', 0, 0, 'ACTIVE', 1, 'USER'),
(@otp_user4, NULL, '0890000104', 'OTP', 'Otp', 'Four', 'OtpFour', '9900000000104', '1996-04-13', 'MALE', 0, 0, 'ACTIVE', 1, 'USER');

INSERT INTO `userphoto` (`userId`, `attributes`) VALUES
(@otp_user1, '{\"urls\":[\"https://example.com/photos/otp1_1.jpg\",\"https://example.com/photos/otp1_2.jpg\"]}'),
(@otp_user2, '{\"urls\":[\"https://example.com/photos/otp2_1.jpg\",\"https://example.com/photos/otp2_2.jpg\"]}'),
(@otp_user3, '{\"urls\":[\"https://example.com/photos/otp3_1.jpg\",\"https://example.com/photos/otp3_2.jpg\"]}'),
(@otp_user4, '{\"urls\":[\"https://example.com/photos/otp4_1.jpg\",\"https://example.com/photos/otp4_2.jpg\"]}');

-- Create matches for multiple rooms
INSERT INTO `match` (`userId1`, `userId2`)
SELECT @otp_user1, @otp_user2
WHERE NOT EXISTS (
  SELECT 1 FROM `match`
  WHERE (`userId1` = @otp_user1 AND `userId2` = @otp_user2)
     OR (`userId1` = @otp_user2 AND `userId2` = @otp_user1)
);
SET @otp_roomA := (
  SELECT `matchId` FROM `match`
  WHERE (`userId1` = @otp_user1 AND `userId2` = @otp_user2)
     OR (`userId1` = @otp_user2 AND `userId2` = @otp_user1)
  ORDER BY `matchId` DESC
  LIMIT 1
);

INSERT INTO `match` (`userId1`, `userId2`)
SELECT @otp_user1, @otp_user3
WHERE NOT EXISTS (
  SELECT 1 FROM `match`
  WHERE (`userId1` = @otp_user1 AND `userId2` = @otp_user3)
     OR (`userId1` = @otp_user3 AND `userId2` = @otp_user1)
);
SET @otp_roomB := (
  SELECT `matchId` FROM `match`
  WHERE (`userId1` = @otp_user1 AND `userId2` = @otp_user3)
     OR (`userId1` = @otp_user3 AND `userId2` = @otp_user1)
  ORDER BY `matchId` DESC
  LIMIT 1
);

INSERT INTO `match` (`userId1`, `userId2`)
SELECT @otp_user2, @otp_user4
WHERE NOT EXISTS (
  SELECT 1 FROM `match`
  WHERE (`userId1` = @otp_user2 AND `userId2` = @otp_user4)
     OR (`userId1` = @otp_user4 AND `userId2` = @otp_user2)
);
SET @otp_roomC := (
  SELECT `matchId` FROM `match`
  WHERE (`userId1` = @otp_user2 AND `userId2` = @otp_user4)
     OR (`userId1` = @otp_user4 AND `userId2` = @otp_user2)
  ORDER BY `matchId` DESC
  LIMIT 1
);

INSERT IGNORE INTO `relationship_stats`
(`relationshipId`, `score`, `streakDays`, `isFirstMessageBonus`, `dailyMessageCount`, `dailyDate`)
VALUES
(@otp_roomA, 85, 4, TRUE, 6, '2026-01-19'),
(@otp_roomB, 42, 1, FALSE, 2, '2026-01-20'),
(@otp_roomC, 10, 0, FALSE, 0, '2026-01-21');

-- Messages for room A
INSERT INTO `messages` (`roomId`, `senderId`, `message`, `messageType`, `isRead`, `createdAt`)
SELECT @otp_roomA, @otp_user1, 'สวัสดีครับ', 'TEXT', TRUE, '2026-01-19 10:30:00'
WHERE NOT EXISTS (
  SELECT 1 FROM `messages` WHERE `roomId` = @otp_roomA AND `senderId` = @otp_user1
    AND `message` = 'สวัสดีครับ' AND `createdAt` = '2026-01-19 10:30:00'
);
INSERT INTO `messages` (`roomId`, `senderId`, `message`, `messageType`, `isRead`, `createdAt`)
SELECT @otp_roomA, @otp_user2, 'สวัสดีค่ะ', 'TEXT', FALSE, '2026-01-19 10:31:00'
WHERE NOT EXISTS (
  SELECT 1 FROM `messages` WHERE `roomId` = @otp_roomA AND `senderId` = @otp_user2
    AND `message` = 'สวัสดีค่ะ' AND `createdAt` = '2026-01-19 10:31:00'
);
INSERT INTO `messages` (`roomId`, `senderId`, `message`, `messageType`, `isRead`, `createdAt`)
SELECT @otp_roomA, @otp_user1, 'อยากคุยกันไหม', 'TEXT', TRUE, '2026-01-19 10:35:00'
WHERE NOT EXISTS (
  SELECT 1 FROM `messages` WHERE `roomId` = @otp_roomA AND `senderId` = @otp_user1
    AND `message` = 'อยากคุยกันไหม' AND `createdAt` = '2026-01-19 10:35:00'
);
INSERT INTO `messages` (`roomId`, `senderId`, `message`, `messageType`, `isRead`, `createdAt`)
SELECT @otp_roomA, @otp_user1, 'มาเล่นเกมกัน', 'GAME', TRUE, '2026-01-19 10:40:00'
WHERE NOT EXISTS (
  SELECT 1 FROM `messages` WHERE `roomId` = @otp_roomA AND `senderId` = @otp_user1
    AND `message` = 'มาเล่นเกมกัน' AND `createdAt` = '2026-01-19 10:40:00'
);

-- Messages for room B
INSERT INTO `messages` (`roomId`, `senderId`, `message`, `messageType`, `isRead`, `createdAt`)
SELECT @otp_roomB, @otp_user1, 'ว่างคุยไหม', 'TEXT', TRUE, '2026-01-20 09:00:00'
WHERE NOT EXISTS (
  SELECT 1 FROM `messages` WHERE `roomId` = @otp_roomB AND `senderId` = @otp_user1
    AND `message` = 'ว่างคุยไหม' AND `createdAt` = '2026-01-20 09:00:00'
);
INSERT INTO `messages` (`roomId`, `senderId`, `message`, `messageType`, `isRead`, `createdAt`)
SELECT @otp_roomB, @otp_user3, 'ได้เลยค่ะ', 'TEXT', FALSE, '2026-01-20 09:05:00'
WHERE NOT EXISTS (
  SELECT 1 FROM `messages` WHERE `roomId` = @otp_roomB AND `senderId` = @otp_user3
    AND `message` = 'ได้เลยค่ะ' AND `createdAt` = '2026-01-20 09:05:00'
);

-- Messages for room C
INSERT INTO `messages` (`roomId`, `senderId`, `message`, `messageType`, `isRead`, `createdAt`)
SELECT @otp_roomC, @otp_user2, 'เย็นนี้ว่างไหม', 'TEXT', TRUE, '2026-01-21 18:10:00'
WHERE NOT EXISTS (
  SELECT 1 FROM `messages` WHERE `roomId` = @otp_roomC AND `senderId` = @otp_user2
    AND `message` = 'เย็นนี้ว่างไหม' AND `createdAt` = '2026-01-21 18:10:00'
);
INSERT INTO `messages` (`roomId`, `senderId`, `message`, `messageType`, `isRead`, `createdAt`)
SELECT @otp_roomC, @otp_user4, 'ว่างครับ', 'TEXT', FALSE, '2026-01-21 18:12:00'
WHERE NOT EXISTS (
  SELECT 1 FROM `messages` WHERE `roomId` = @otp_roomC AND `senderId` = @otp_user4
    AND `message` = 'ว่างครับ' AND `createdAt` = '2026-01-21 18:12:00'
);

-- Chat access logs
INSERT INTO `chat_access_logs` (`userId`, `roomId`, `actionType`, `createdAt`)
SELECT @otp_user1, @otp_roomA, 'ENTER', '2026-01-19 10:50:00'
WHERE NOT EXISTS (
  SELECT 1 FROM `chat_access_logs` WHERE `userId` = @otp_user1 AND `roomId` = @otp_roomA
    AND `actionType` = 'ENTER' AND `createdAt` = '2026-01-19 10:50:00'
);
INSERT INTO `chat_access_logs` (`userId`, `roomId`, `actionType`, `createdAt`)
SELECT @otp_user2, @otp_roomA, 'EXIT', '2026-01-19 10:52:00'
WHERE NOT EXISTS (
  SELECT 1 FROM `chat_access_logs` WHERE `userId` = @otp_user2 AND `roomId` = @otp_roomA
    AND `actionType` = 'EXIT' AND `createdAt` = '2026-01-19 10:52:00'
);

-- Game session for room A
INSERT INTO `game_sessions` (`gameId`, `roomId`, `totalScore`, `status`) VALUES
('game_otp_a', @otp_roomA, 12, 'ACTIVE')
ON DUPLICATE KEY UPDATE
`totalScore` = VALUES(`totalScore`),
`status` = VALUES(`status`);

INSERT INTO `game_questions` (`questionId`, `gameId`, `question`, `options`, `correctAnswer`, `userSelectedOption`, `isCorrect`) VALUES
('q_otp_a_1', 'game_otp_a', 'First date idea?', '[\"Cafe\",\"Park\",\"Movie\",\"Beach\"]', 'Cafe', 'Park', FALSE)
ON DUPLICATE KEY UPDATE
`userSelectedOption` = VALUES(`userSelectedOption`),
`isCorrect` = VALUES(`isCorrect`);

-- Reports
INSERT INTO `reports` (`reporterId`, `targetUserId`, `reason`, `anotherReason`, `description`, `status`, `isNotified`)
SELECT @otp_user2, @otp_user3, 'spam', NULL, 'Test report from OTP user', 'PENDING', FALSE
WHERE NOT EXISTS (
  SELECT 1 FROM `reports`
  WHERE `reporterId` = @otp_user2 AND `targetUserId` = @otp_user3
);
SET @otp_reportId := (
  SELECT `reportId` FROM `reports`
  WHERE `reporterId` = @otp_user2 AND `targetUserId` = @otp_user3
  ORDER BY `reportId` DESC
  LIMIT 1
);

INSERT INTO `report_evidences` (`reportId`, `evidenceUrl`)
SELECT @otp_reportId, '[\"https://example.com/evidence/otp-report-1.jpg\"]'
WHERE NOT EXISTS (
  SELECT 1 FROM `report_evidences` WHERE `reportId` = @otp_reportId
);
