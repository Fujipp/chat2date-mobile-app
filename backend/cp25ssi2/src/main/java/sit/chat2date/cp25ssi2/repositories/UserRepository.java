package sit.chat2date.cp25ssi2.repositories;

import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import sit.chat2date.cp25ssi2.entities.User;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByEmail(String email);
    Optional<User> findByPhoneNumber(String phoneNumber);
    Optional<User> findByUserId(String userId);

    User findUsersByUserId(String userId);
    User findUsersByPhoneNumber(String phoneNumber);
    List<User> findByDeleteFlagTrueAndDeletedAtBefore(LocalDateTime date);

    @Query(value = """
    SELECT DISTINCT u.*
    FROM user u
    JOIN userlocation loc ON u.userId = loc.userId
    LEFT JOIN action a
               ON a.userId       = :currentUserId
              AND a.targetUserId = u.userId
    WHERE u.userId != :currentUserId
      AND a.actionId IS NULL
      AND u.accountStatus = 'ACTIVE'
      AND u.isBlacklist = 0
      AND (:interestedGender = 'BOTH' OR u.sex = :interestedGender)
      AND (
        6371 * acos(
          cos(radians(:myLat)) * cos(radians(loc.latitude)) *
          cos(radians(loc.longitude) - radians(:myLon)) +
          sin(radians(:myLat)) * sin(radians(loc.latitude))
        )
      ) BETWEEN :minDistance AND :maxDistance
      AND TIMESTAMPDIFF(YEAR, u.birthday, CURDATE()) BETWEEN :minAge AND :maxAge
    LIMIT :limit
""", nativeQuery = true)
    List<User> findCandidatesBasic(
            @Param("currentUserId") String currentUserId,
            @Param("myLat") double myLat,
            @Param("myLon") double myLon,
            @Param("minDistance") int minDistance,
            @Param("maxDistance") int maxDistance,
            @Param("minAge") int minAge,
            @Param("maxAge") int maxAge,
            @Param("interestedGender") String interestedGender,
            @Param("limit") int limit
    );

    @Query(value = """
        SELECT DISTINCT u.*
        FROM user u
        JOIN userlocation loc ON u.userId = loc.userId
        LEFT JOIN action a
              ON a.userId        = :currentUserId
             AND a.targetUserId  = u.userId
        LEFT JOIN (
            SELECT uht.user_userId AS userId, COUNT(*) AS commonTravelStyles
            FROM user_has_travelstyle uht
            WHERE uht.travelstyle_travelId IN (
                SELECT travelstyle_travelId 
                FROM user_has_travelstyle
                WHERE user_userId = :currentUserId
            )
            GROUP BY uht.user_userId
        ) travel ON travel.userId = u.userId
        LEFT JOIN (
            SELECT uhl.user_userId AS userId, COUNT(*) AS commonLifestyles
            FROM user_has_lifestyle uhl
            WHERE uhl.lifestyle_lifestyleId IN (
                SELECT lifestyle_lifestyleId 
                FROM user_has_lifestyle 
                WHERE user_userId = :currentUserId
            )
            GROUP BY uhl.user_userId
        ) lifestyle ON lifestyle.userId = u.userId
        LEFT JOIN (
            SELECT uhi.user_userId AS userId, COUNT(*) AS commonInterests
            FROM user_has_interest uhi
            WHERE uhi.interest_interestId IN (
                SELECT interest_interestId 
                FROM user_has_interest 
                WHERE user_userId = :currentUserId
            )
            GROUP BY uhi.user_userId
        ) interest ON interest.userId = u.userId
        WHERE u.userId != :currentUserId
          AND u.accountStatus = 'ACTIVE'
          AND a.actionId IS NULL
          AND u.isBlacklist = 0
          AND (:interestedGender = 'BOTH' OR u.sex = :interestedGender)
          AND (
            6371 * acos(
              cos(radians(:myLat)) * cos(radians(loc.latitude)) *
              cos(radians(loc.longitude) - radians(:myLon)) +
              sin(radians(:myLat)) * sin(radians(loc.latitude))
            )
          ) BETWEEN :minDistance AND :maxDistance
          AND TIMESTAMPDIFF(YEAR, u.birthday, CURDATE()) BETWEEN :minAge AND :maxAge

          -- ✅ Travel Style (2-3 อัน): SAME = ตรงทั้งหมด (2/2 หรือ 3/3), NEARLY = ตรงบางส่วน, UNRELATED = ตรง 0 อัน
          AND (
            :travelPref = 'UNNECESSARY'
            OR (:travelPref = 'SAME' AND IFNULL(travel.commonTravelStyles, 0) = :userTravelCount)
            OR (:travelPref = 'NEARLY' AND IFNULL(travel.commonTravelStyles, 0) > 0 
                AND IFNULL(travel.commonTravelStyles, 0) < :userTravelCount)
            OR (:travelPref = 'UNRELATED' AND IFNULL(travel.commonTravelStyles, 0) = 0)
          )

          -- ✅ Lifestyle (3-5 อัน): SAME = ตรงทั้งหมด, NEARLY = ตรงบางส่วน, UNRELATED = ตรง 0 อัน
          AND (
            :lifestylePref = 'UNNECESSARY'
            OR (:lifestylePref = 'SAME' AND IFNULL(lifestyle.commonLifestyles, 0) = :userLifestyleCount)
            OR (:lifestylePref = 'NEARLY' AND IFNULL(lifestyle.commonLifestyles, 0) > 0 
                AND IFNULL(lifestyle.commonLifestyles, 0) < :userLifestyleCount)
            OR (:lifestylePref = 'UNRELATED' AND IFNULL(lifestyle.commonLifestyles, 0) = 0)
          )

          -- ✅ Interest (3-5 อัน): SAME = ตรงทั้งหมด, NEARLY = ตรงบางส่วน, UNRELATED = ตรง 0 อัน
          AND (
            :interestPref = 'UNNECESSARY'
            OR (:interestPref = 'SAME' AND IFNULL(interest.commonInterests, 0) = :userInterestCount)
            OR (:interestPref = 'NEARLY' AND IFNULL(interest.commonInterests, 0) > 0 
                AND IFNULL(interest.commonInterests, 0) < :userInterestCount)
            OR (:interestPref = 'UNRELATED' AND IFNULL(interest.commonInterests, 0) = 0)
          )

        ORDER BY RAND()
        LIMIT :limit
      """, nativeQuery = true)
    List<User> findCandidatesWithPreference(
            @Param("currentUserId") String currentUserId,
            @Param("myLat") double myLat,
            @Param("myLon") double myLon,
            @Param("minDistance") int minDistance,
            @Param("maxDistance") int maxDistance,
            @Param("minAge") int minAge,
            @Param("maxAge") int maxAge,
            @Param("interestedGender") String interestedGender,
            @Param("travelPref") String travelPref,
            @Param("lifestylePref") String lifestylePref,
            @Param("interestPref") String interestPref,
            @Param("userTravelCount") int userTravelCount,
            @Param("userLifestyleCount") int userLifestyleCount,
            @Param("userInterestCount") int userInterestCount,
            @Param("limit") int limit
    );
}