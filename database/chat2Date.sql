-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema chat2date
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema chat2date
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `chat2date` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `chat2date` ;

-- -----------------------------------------------------
-- Table `chat2date`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`user` (
  `userId` VARCHAR(36) NOT NULL,
  `email` VARCHAR(100) NULL DEFAULT NULL,
  `phoneNumber` VARCHAR(10) NULL DEFAULT NULL,
  `provider` ENUM('GOOGLE', 'OTP') NOT NULL,
  `firstname` VARCHAR(50) NOT NULL,
  `lastname` VARCHAR(50) NOT NULL,
  `nickname` VARCHAR(30) NOT NULL,
  `cardId` VARCHAR(13) NOT NULL,
  `birthday` DATE NOT NULL,
  `sex` ENUM('MALE', 'FEMALE') NOT NULL,
  `behaviorScore` INT NOT NULL DEFAULT '0',
  `isBlacklist` TINYINT NOT NULL DEFAULT '0',
  `accountStatus` ENUM('ACTIVE', 'SUSPENDED', 'PENDING') NOT NULL DEFAULT 'PENDING',
  `version` INT NOT NULL,
  `role` ENUM('USER', 'ADMIN') NOT NULL,
  `deleted_at` TIMESTAMP NULL DEFAULT NULL,
  `delete_flag` TINYINT(1) NULL DEFAULT '0',
  `isTutorial` TINYINT(1) NULL DEFAULT '0',
  PRIMARY KEY (`userId`),
  UNIQUE INDEX `cardId` (`cardId` ASC) VISIBLE,
  UNIQUE INDEX `Email` (`email` ASC) VISIBLE,
  UNIQUE INDEX `PhoneNumber` (`phoneNumber` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`action`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`action` (
  `actionId` INT NOT NULL AUTO_INCREMENT,
  `userId` VARCHAR(36) NOT NULL,
  `actionType` ENUM('LIKE', 'DISLIKE') NOT NULL,
  `targetUserId` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`actionId`),
  UNIQUE INDEX `actionId_UNIQUE` (`actionId` ASC) VISIBLE,
  INDEX `userId` (`userId` ASC) VISIBLE,
  INDEX `targetUserId` (`targetUserId` ASC) VISIBLE,
  CONSTRAINT `actiontable_ibfk_1`
    FOREIGN KEY (`userId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE,
  CONSTRAINT `actiontable_ibfk_2`
    FOREIGN KEY (`targetUserId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 420
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`match`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`match` (
  `matchId` INT NOT NULL AUTO_INCREMENT,
  `userId1` VARCHAR(36) NOT NULL,
  `userId2` VARCHAR(36) NOT NULL,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` TIMESTAMP NULL DEFAULT NULL,
  `delete_flag` TINYINT(1) NULL DEFAULT '0',
  PRIMARY KEY (`matchId`),
  UNIQUE INDEX `matchId_UNIQUE` (`matchId` ASC) VISIBLE,
  INDEX `userId1` (`userId1` ASC) VISIBLE,
  INDEX `userId2` (`userId2` ASC) VISIBLE,
  CONSTRAINT `matchtable_ibfk_1`
    FOREIGN KEY (`userId1`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE,
  CONSTRAINT `matchtable_ibfk_2`
    FOREIGN KEY (`userId2`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 117
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`places`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`places` (
  `placeId` VARCHAR(255) NOT NULL,
  `placeName` VARCHAR(255) NOT NULL,
  `address` TEXT NULL DEFAULT NULL,
  `imageUrl` TEXT NULL DEFAULT NULL,
  `latitude` DECIMAL(11,8) NOT NULL,
  `longitude` DECIMAL(11,8) NOT NULL,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`placeId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`appointments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`appointments` (
  `appointmentId` INT NOT NULL AUTO_INCREMENT,
  `roomId` INT NOT NULL,
  `placeId` VARCHAR(255) NOT NULL,
  `dateTime` DATETIME NULL DEFAULT NULL,
  `status` ENUM('PLACE_SELECTED', 'SCHEDULED', 'CANCELLED', 'COMPLETED') NOT NULL DEFAULT 'PLACE_SELECTED',
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `isNotified` TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`appointmentId`),
  INDEX `idx_appointments_roomId` (`roomId` ASC) VISIBLE,
  INDEX `idx_appointments_placeId` (`placeId` ASC) VISIBLE,
  CONSTRAINT `fk_appointments_match`
    FOREIGN KEY (`roomId`)
    REFERENCES `chat2date`.`match` (`matchId`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_appointments_place`
    FOREIGN KEY (`placeId`)
    REFERENCES `chat2date`.`places` (`placeId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 97
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`chat_access_logs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`chat_access_logs` (
  `chatAccessId` BIGINT NOT NULL AUTO_INCREMENT,
  `userId` VARCHAR(36) NOT NULL,
  `roomId` INT NOT NULL,
  `actionType` ENUM('ENTER', 'EXIT') NOT NULL,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`chatAccessId`),
  INDEX `fk_logs_user` (`userId` ASC) VISIBLE,
  INDEX `fk_logs_match` (`roomId` ASC) VISIBLE,
  CONSTRAINT `fk_logs_match`
    FOREIGN KEY (`roomId`)
    REFERENCES `chat2date`.`match` (`matchId`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_logs_user`
    FOREIGN KEY (`userId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 439
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`contact_messages`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`contact_messages` (
  `contactId` INT NOT NULL AUTO_INCREMENT,
  `userId` VARCHAR(36) NOT NULL,
  `contactName` VARCHAR(100) NULL DEFAULT NULL,
  `contactEmail` VARCHAR(100) NULL DEFAULT NULL,
  `subject` VARCHAR(100) NOT NULL,
  `message` TEXT NOT NULL,
  `status` ENUM('NEW', 'IN_PROGRESS', 'RESOLVED') NOT NULL DEFAULT 'NEW',
  `repliedAt` TIMESTAMP NULL DEFAULT NULL,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`contactId`),
  INDEX `idx_contact_user` (`userId` ASC) VISIBLE,
  INDEX `idx_contact_status` (`status` ASC) VISIBLE,
  CONSTRAINT `fk_contact_user`
    FOREIGN KEY (`userId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 106
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`devicetoken`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`devicetoken` (
  `devicetokenId` INT NOT NULL AUTO_INCREMENT,
  `userId` VARCHAR(36) NOT NULL,
  `fcmToken` VARCHAR(512) NOT NULL,
  `platform` VARCHAR(20) NULL DEFAULT NULL,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`devicetokenId`),
  UNIQUE INDEX `uk_user_token` (`userId` ASC, `fcmToken` ASC) VISIBLE,
  INDEX `userId_idx` (`userId` ASC) VISIBLE,
  CONSTRAINT `devicetoken_ibfk_1`
    FOREIGN KEY (`userId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 94
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`emergencycontact`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`emergencycontact` (
  `emergencyId` INT NOT NULL AUTO_INCREMENT,
  `telephoneNumber` VARCHAR(10) NOT NULL,
  `userId` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`emergencyId`),
  INDEX `userId` (`userId` ASC) VISIBLE,
  CONSTRAINT `emergencycontact_ibfk_1`
    FOREIGN KEY (`userId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 125
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`game_sessions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`game_sessions` (
  `gameId` VARCHAR(50) NOT NULL,
  `roomId` INT NOT NULL,
  `totalScore` INT NOT NULL DEFAULT '0',
  `status` ENUM('ACTIVE', 'COMPLETED', 'FAILED') NOT NULL DEFAULT 'ACTIVE',
  `targetScore` INT NOT NULL DEFAULT '25',
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`gameId`),
  INDEX `fk_game_match` (`roomId` ASC) VISIBLE,
  CONSTRAINT `fk_game_match`
    FOREIGN KEY (`roomId`)
    REFERENCES `chat2date`.`match` (`matchId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`game_questions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`game_questions` (
  `questionId` VARCHAR(50) NOT NULL,
  `gameId` VARCHAR(50) NOT NULL,
  `question` TEXT NOT NULL,
  `options` JSON NOT NULL,
  `correctAnswer` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`questionId`),
  INDEX `fk_questions_session` (`gameId` ASC) VISIBLE,
  CONSTRAINT `fk_questions_session`
    FOREIGN KEY (`gameId`)
    REFERENCES `chat2date`.`game_sessions` (`gameId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`game_answers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`game_answers` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `gameId` VARCHAR(50) NOT NULL,
  `questionId` VARCHAR(50) NOT NULL,
  `userId` VARCHAR(50) NOT NULL,
  `selectedOption` VARCHAR(255) NOT NULL,
  `isCorrect` TINYINT(1) NOT NULL,
  `answeredAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uq_user_question` (`userId` ASC, `questionId` ASC) VISIBLE,
  INDEX `fk_answers_session` (`gameId` ASC) VISIBLE,
  INDEX `fk_answers_question` (`questionId` ASC) VISIBLE,
  CONSTRAINT `fk_answers_question`
    FOREIGN KEY (`questionId`)
    REFERENCES `chat2date`.`game_questions` (`questionId`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_answers_session`
    FOREIGN KEY (`gameId`)
    REFERENCES `chat2date`.`game_sessions` (`gameId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 735
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`interest`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`interest` (
  `interestId` INT NOT NULL AUTO_INCREMENT,
  `interest` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`interestId`),
  UNIQUE INDEX `interest_UNIQUE` (`interest` ASC) VISIBLE,
  UNIQUE INDEX `interestId_UNIQUE` (`interestId` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 167
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`lifestyle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`lifestyle` (
  `lifestyleId` INT NOT NULL AUTO_INCREMENT,
  `lifeStyle` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`lifestyleId`),
  UNIQUE INDEX `lifestyle_UNIQUE` (`lifeStyle` ASC) VISIBLE,
  UNIQUE INDEX `lifestyleId_UNIQUE` (`lifestyleId` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 82
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`messages`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`messages` (
  `messageId` BIGINT NOT NULL AUTO_INCREMENT,
  `roomId` INT NOT NULL,
  `senderId` VARCHAR(36) NULL DEFAULT NULL,
  `message` TEXT NOT NULL,
  `messageType` ENUM('TEXT', 'GAME', 'SUCCESS', 'FAIL', 'DATE') NOT NULL DEFAULT 'TEXT',
  `isRead` TINYINT(1) NOT NULL DEFAULT '0',
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`messageId`),
  INDEX `idx_roomId` (`roomId` ASC) VISIBLE,
  INDEX `fk_messages_user` (`senderId` ASC) VISIBLE,
  CONSTRAINT `fk_messages_match`
    FOREIGN KEY (`roomId`)
    REFERENCES `chat2date`.`match` (`matchId`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_messages_user`
    FOREIGN KEY (`senderId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE SET NULL)
ENGINE = InnoDB
AUTO_INCREMENT = 2105
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`place_confirmations`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`place_confirmations` (
  `confirmId` INT NOT NULL AUTO_INCREMENT,
  `roomId` INT NOT NULL,
  `placeId` VARCHAR(255) NOT NULL,
  `user1Confirmed` ENUM('AGREED', 'DISAGREED', 'BLANK') NOT NULL DEFAULT 'BLANK',
  `user2Confirmed` ENUM('AGREED', 'DISAGREED', 'BLANK') NOT NULL DEFAULT 'BLANK',
  `status` ENUM('PENDING', 'AGREED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`confirmId`),
  INDEX `fk_confirm_match` (`roomId` ASC) VISIBLE,
  INDEX `fk_confirm_place` (`placeId` ASC) VISIBLE,
  CONSTRAINT `fk_confirm_match`
    FOREIGN KEY (`roomId`)
    REFERENCES `chat2date`.`match` (`matchId`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_confirm_place`
    FOREIGN KEY (`placeId`)
    REFERENCES `chat2date`.`places` (`placeId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 120
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`post_trip_reviews`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`post_trip_reviews` (
  `reviewId` INT NOT NULL AUTO_INCREMENT,
  `appointmentId` INT NOT NULL,
  `reviewerId` VARCHAR(36) NOT NULL,
  `targetUserId` VARCHAR(36) NOT NULL,
  `isSatisfied` TINYINT(1) NOT NULL,
  `wantToContinue` TINYINT(1) NULL DEFAULT NULL,
  `wantToUnmatch` TINYINT(1) NULL DEFAULT NULL,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reviewId`),
  INDEX `fk_review_appointment` (`appointmentId` ASC) VISIBLE,
  INDEX `fk_review_reviewer` (`reviewerId` ASC) VISIBLE,
  INDEX `fk_review_target` (`targetUserId` ASC) VISIBLE,
  CONSTRAINT `fk_review_appointment`
    FOREIGN KEY (`appointmentId`)
    REFERENCES `chat2date`.`appointments` (`appointmentId`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_review_reviewer`
    FOREIGN KEY (`reviewerId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_review_target`
    FOREIGN KEY (`targetUserId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 181
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`preferencematch`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`preferencematch` (
  `preferenceId` INT NOT NULL AUTO_INCREMENT,
  `interestedGender` ENUM('MALE', 'FEMALE', 'BOTH') NOT NULL,
  `interestedTravelStyle` ENUM('SAME', 'NEARLY', 'UNRELATED', 'UNNECESSARY') NOT NULL,
  `interestedLifeStyle` ENUM('SAME', 'NEARLY', 'UNRELATED', 'UNNECESSARY') NOT NULL,
  `interestedInterest` ENUM('SAME', 'NEARLY', 'UNRELATED', 'UNNECESSARY') NOT NULL,
  `interestedAgeMin` INT NOT NULL,
  `interestedAgeMax` INT NOT NULL,
  `interestedDistanceMin` INT NOT NULL,
  `interestedDistanceMax` INT NOT NULL,
  `userId` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`preferenceId`),
  UNIQUE INDEX `userId_UNIQUE` (`userId` ASC) VISIBLE,
  INDEX `userId` (`userId` ASC) VISIBLE,
  CONSTRAINT `preferencematch_ibfk_1`
    FOREIGN KEY (`userId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 65
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`relationship_stats`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`relationship_stats` (
  `relationshipId` INT NOT NULL,
  `score` INT NOT NULL DEFAULT '0',
  `streakDays` INT NOT NULL DEFAULT '0',
  `isFirstMessageBonus` TINYINT(1) NOT NULL DEFAULT '0',
  `dailyMessageCount` INT NOT NULL DEFAULT '0',
  `dailyDate` DATE NULL DEFAULT NULL,
  `isDailyMessageBonus` TINYINT(1) NOT NULL DEFAULT '0',
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `notiBeforeUnmatch` ENUM('NONE', 'LEFT', 'RIGHT', 'BOTH') NOT NULL DEFAULT 'NONE',
  `notiUnmatch` ENUM('NONE', 'LEFT', 'RIGHT', 'BOTH') NOT NULL DEFAULT 'NONE',
  PRIMARY KEY (`relationshipId`),
  CONSTRAINT `fk_relationship_match`
    FOREIGN KEY (`relationshipId`)
    REFERENCES `chat2date`.`match` (`matchId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`reports`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`reports` (
  `reportId` INT NOT NULL AUTO_INCREMENT,
  `reporterId` VARCHAR(36) NOT NULL,
  `targetUserId` VARCHAR(36) NOT NULL,
  `reason` VARCHAR(100) NOT NULL,
  `anotherReason` TEXT NULL DEFAULT NULL,
  `description` TEXT NULL DEFAULT NULL,
  `status` ENUM('PENDING', 'RESOLVED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
  `isNotified` TINYINT(1) NOT NULL DEFAULT '0',
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reportId`),
  INDEX `fk_report_reporter` (`reporterId` ASC) VISIBLE,
  INDEX `fk_report_target` (`targetUserId` ASC) VISIBLE,
  CONSTRAINT `fk_report_reporter`
    FOREIGN KEY (`reporterId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_report_target`
    FOREIGN KEY (`targetUserId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 70
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`report_evidences`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`report_evidences` (
  `evidenceId` INT NOT NULL AUTO_INCREMENT,
  `reportId` INT NOT NULL,
  `evidenceUrl` JSON NOT NULL,
  PRIMARY KEY (`evidenceId`),
  INDEX `fk_evidence_report` (`reportId` ASC) VISIBLE,
  CONSTRAINT `fk_evidence_report`
    FOREIGN KEY (`reportId`)
    REFERENCES `chat2date`.`reports` (`reportId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 15
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`sos_incidents`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`sos_incidents` (
  `incidentId` INT NOT NULL AUTO_INCREMENT,
  `appointmentId` INT NOT NULL,
  `reporterId` VARCHAR(36) NOT NULL,
  `targetUserId` VARCHAR(36) NOT NULL,
  `latitude` DECIMAL(11,8) NOT NULL,
  `longitude` DECIMAL(11,8) NOT NULL,
  `calledNumber` VARCHAR(15) NOT NULL,
  `status` ENUM('NEW', 'INVESTIGATING', 'RESOLVED') NOT NULL DEFAULT 'NEW',
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`incidentId`),
  INDEX `idx_sos_appointment` (`appointmentId` ASC) VISIBLE,
  INDEX `fk_sos_reporter` (`reporterId` ASC) VISIBLE,
  INDEX `fk_sos_target` (`targetUserId` ASC) VISIBLE,
  CONSTRAINT `fk_sos_appointment`
    FOREIGN KEY (`appointmentId`)
    REFERENCES `chat2date`.`appointments` (`appointmentId`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_sos_reporter`
    FOREIGN KEY (`reporterId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_sos_target`
    FOREIGN KEY (`targetUserId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 100
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`swipe_quota`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`swipe_quota` (
  `quotaId` INT NOT NULL AUTO_INCREMENT,
  `userId` VARCHAR(36) NOT NULL,
  `swipeCount` INT NOT NULL DEFAULT '0',
  `swipeDate` DATE NULL DEFAULT NULL,
  `restrictUntil` TIMESTAMP NULL DEFAULT NULL,
  `lastReportAt` DATE NULL DEFAULT NULL,
  PRIMARY KEY (`quotaId`),
  UNIQUE INDEX `uk_swipe_quota_user` (`userId` ASC) VISIBLE,
  CONSTRAINT `fk_swipe_quota_user`
    FOREIGN KEY (`userId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 13
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`tag`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`tag` (
  `tagId` INT NOT NULL AUTO_INCREMENT,
  `tag` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`tagId`),
  UNIQUE INDEX `tag_UNIQUE` (`tag` ASC) VISIBLE,
  UNIQUE INDEX `tagId_UNIQUE` (`tagId` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 91
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`travelstyle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`travelstyle` (
  `travelId` INT NOT NULL AUTO_INCREMENT,
  `travelStyle` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`travelId`),
  UNIQUE INDEX `travelId_UNIQUE` (`travelId` ASC) VISIBLE,
  UNIQUE INDEX `travelStyle_UNIQUE` (`travelStyle` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`user_has_interest`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`user_has_interest` (
  `user_userId` VARCHAR(36) NOT NULL,
  `interest_interestId` INT NOT NULL,
  PRIMARY KEY (`user_userId`, `interest_interestId`),
  INDEX `fk_user_has_interest_interest1_idx` (`interest_interestId` ASC) VISIBLE,
  INDEX `fk_user_has_interest_user1_idx` (`user_userId` ASC) VISIBLE,
  CONSTRAINT `fk_user_has_interest_interest1`
    FOREIGN KEY (`interest_interestId`)
    REFERENCES `chat2date`.`interest` (`interestId`),
  CONSTRAINT `fk_user_has_interest_user1`
    FOREIGN KEY (`user_userId`)
    REFERENCES `chat2date`.`user` (`userId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`user_has_lifestyle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`user_has_lifestyle` (
  `user_userId` VARCHAR(36) NOT NULL,
  `lifestyle_lifestyleId` INT NOT NULL,
  PRIMARY KEY (`user_userId`, `lifestyle_lifestyleId`),
  INDEX `fk_user_has_lifestyle_lifestyle1_idx` (`lifestyle_lifestyleId` ASC) VISIBLE,
  INDEX `fk_user_has_lifestyle_user1_idx` (`user_userId` ASC) VISIBLE,
  CONSTRAINT `fk_user_has_lifestyle_lifestyle1`
    FOREIGN KEY (`lifestyle_lifestyleId`)
    REFERENCES `chat2date`.`lifestyle` (`lifestyleId`),
  CONSTRAINT `fk_user_has_lifestyle_user1`
    FOREIGN KEY (`user_userId`)
    REFERENCES `chat2date`.`user` (`userId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`user_has_tag`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`user_has_tag` (
  `user_userId` VARCHAR(36) NOT NULL,
  `tag_tagId` INT NOT NULL,
  PRIMARY KEY (`user_userId`, `tag_tagId`),
  INDEX `fk_user_has_tag_tag1_idx` (`tag_tagId` ASC) VISIBLE,
  INDEX `fk_user_has_tag_user1_idx` (`user_userId` ASC) VISIBLE,
  CONSTRAINT `fk_user_has_tag_tag1`
    FOREIGN KEY (`tag_tagId`)
    REFERENCES `chat2date`.`tag` (`tagId`),
  CONSTRAINT `fk_user_has_tag_user1`
    FOREIGN KEY (`user_userId`)
    REFERENCES `chat2date`.`user` (`userId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`user_has_travelstyle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`user_has_travelstyle` (
  `user_userId` VARCHAR(36) NOT NULL,
  `travelstyle_travelId` INT NOT NULL,
  PRIMARY KEY (`user_userId`, `travelstyle_travelId`),
  INDEX `fk_user_has_travelstyle_travelstyle1_idx` (`travelstyle_travelId` ASC) VISIBLE,
  INDEX `fk_user_has_travelstyle_user1_idx` (`user_userId` ASC) VISIBLE,
  CONSTRAINT `fk_user_has_travelstyle_travelstyle1`
    FOREIGN KEY (`travelstyle_travelId`)
    REFERENCES `chat2date`.`travelstyle` (`travelId`),
  CONSTRAINT `fk_user_has_travelstyle_user1`
    FOREIGN KEY (`user_userId`)
    REFERENCES `chat2date`.`user` (`userId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`userlocation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`userlocation` (
  `locationId` INT NOT NULL AUTO_INCREMENT,
  `latitude` DECIMAL(11,8) NOT NULL,
  `longitude` DECIMAL(11,8) NOT NULL,
  `accuracy` DECIMAL(6,2) NOT NULL,
  `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `userId` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`locationId`),
  UNIQUE INDEX `userId_UNIQUE` (`userId` ASC) VISIBLE,
  INDEX `userId` (`userId` ASC) VISIBLE,
  CONSTRAINT `userlocation_ibfk_1`
    FOREIGN KEY (`userId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 78
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `chat2date`.`userphoto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `chat2date`.`userphoto` (
  `photoId` INT NOT NULL AUTO_INCREMENT,
  `userId` VARCHAR(36) NOT NULL,
  `attributes` JSON NOT NULL,
  `base64Card` LONGTEXT NULL DEFAULT NULL,
  `isVerified` TINYINT(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`photoId`),
  INDEX `userId` (`userId` ASC) VISIBLE,
  CONSTRAINT `userphoto_ibfk_1`
    FOREIGN KEY (`userId`)
    REFERENCES `chat2date`.`user` (`userId`)
    ON DELETE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 30
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
