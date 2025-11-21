package sit.chat2date.cp25ssi2.repositories;

import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import sit.chat2date.cp25ssi2.entities.User;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByEmail(String email);
    Optional<User> findByPhoneNumber(String phoneNumber);
    Optional<User> findByUserId(String userId);

    User findUsersByUserId(String userId);

    @Query(
            value = """
        SELECT DISTINCT u.*
        FROM user u
        JOIN userlocation loc ON u.userId = loc.userId
        LEFT JOIN (
            SELECT uht.useruserId AS userId, COUNT(*) AS commonTravelStyles
            FROM userhastravelstyle uht
            WHERE uht.travelstyletravelId IN (
                SELECT travelstyletravelId 
                FROM userhastravelstyle 
                WHERE useruserId = :currentUserId
            )
            GROUP BY uht.useruserId
        ) travel ON travel.userId = u.userId
        LEFT JOIN (
            SELECT uhl.useruserId AS userId, COUNT(*) AS commonLifestyles
            FROM userhaslifestyle uhl
            WHERE uhl.lifestylelifestyleId IN (
                SELECT lifestylelifestyleId 
                FROM userhaslifestyle 
                WHERE useruserId = :currentUserId
            )
            GROUP BY uhl.useruserId
        ) lifestyle ON lifestyle.userId = u.userId
        LEFT JOIN (
            SELECT uhi.useruserId AS userId, COUNT(*) AS commonInterests
            FROM userhasinterest uhi
            WHERE uhi.interestinterestId IN (
                SELECT interestinterestId 
                FROM userhasinterest 
                WHERE useruserId = :currentUserId
            )
            GROUP BY uhi.useruserId
        ) interest ON interest.userId = u.userId
        WHERE u.userId != :currentUserId
          AND u.accountStatus = 'ACTIVE'
          AND u.isBlacklist = 0
          AND u.sex = :interestedGender
          AND (
            6371 * acos(
              cos(radians(:myLat)) * cos(radians(loc.latitude)) *
              cos(radians(loc.longtitude) - radians(:myLon)) +
              sin(radians(:myLat)) * sin(radians(loc.latitude))
            )
          ) BETWEEN :minDistance AND :maxDistance
          AND TIMESTAMPDIFF(YEAR, u.birthday, CURDATE()) BETWEEN :minAge AND :maxAge

          -- Filter ตาม preference
          AND (:travelPref != 'SAME' OR travel.commonTravelStyles >= CEIL(:userTravelCount * 0.5))
          AND (:lifestylePref != 'SAME' OR lifestyle.commonLifestyles >= CEIL(:userLifestyleCount * 0.5))
          AND (:interestPref != 'SAME' OR interest.commonInterests >= CEIL(:userInterestCount * 0.5))
          AND (:travelPref != 'UNRELATED' OR IFNULL(travel.commonTravelStyles, 0) = 0)
          AND (:lifestylePref != 'UNRELATED' OR IFNULL(lifestyle.commonLifestyles, 0) = 0)
          AND (:interestPref != 'UNRELATED' OR IFNULL(interest.commonInterests, 0) = 0)

        ORDER BY RAND()
        LIMIT :limit
      """,
            nativeQuery = true)
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