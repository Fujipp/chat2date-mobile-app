package sit.chat2date.cp25ssi2.services;

import com.auth0.jwt.JWT;
import com.auth0.jwt.interfaces.DecodedJWT;
import jakarta.transaction.Transactional;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.BeanWrapperImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.dto.PreferenceMatchUserDTO;
import sit.chat2date.cp25ssi2.dto.PreferenceUserDTO;
import sit.chat2date.cp25ssi2.dto.PreferenceUserProfileDTO;
import sit.chat2date.cp25ssi2.entities.*;
import sit.chat2date.cp25ssi2.enums.PreferenceGender;
import sit.chat2date.cp25ssi2.enums.PreferenceLevel;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceptions.PreconditionFailedException;
import sit.chat2date.cp25ssi2.repositories.*;

import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.function.BiFunction;
import java.util.function.Consumer;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private InterestRepository interestRepository;
    @Autowired
    private UserHasInterestRepository userHasInterestRepository;
    @Autowired
    private TagRepository tagRepository;
    @Autowired
    private UserHasTagRepository userHasTagRepository;
    @Autowired
    private LifeStyleRepository lifeStyleRepository;
    @Autowired
    private UserHasLifestyleRepository userHasLifestyleRepository;
    @Autowired
    private TravelStyleRepository travelStyleRepository;
    @Autowired
    private UserHasTravelstyleRepository userHasTravelstyleRepository;
    @Autowired
    private PreferenceMatchRepository preferenceMatchRepository;
    @Autowired
    private UserPhotoRepository userPhotoRepository;

    public User createUser(User user) {
        return userRepository.save(user);
    }

    public ResponseEntity<User> updateUserById(String id, @RequestBody User user) {
        User userById = userRepository.findByUserId(id).orElseThrow(() -> new NotFoundException("User id: " + id + " not found"));
        if (!user.getVersion().equals(userById.getVersion())) {
            throw new PreconditionFailedException("version", "mismatch");
        }
        BeanUtils.copyProperties(user, userById, getNullPropertyNames(user));
        if (user.getCardId() != null) {
            userById.setCardId(user.getCardId());
        }
        if (user.getIsBlacklist() != null) {
            userById.setIsBlacklist(user.getIsBlacklist());
        }
        if (user.getRole() != null) {
            userById.setRole(user.getRole());
        }
        if (user.getEmail() != null) {
            userById.setProvider(user.getProvider());
        }
        if (user.getSex() != null) {
            userById.setSex(user.getSex());
        }
        if (user.getAccountStatus() != null) {
            userById.setAccountStatus(user.getAccountStatus());
        }

        userById.setVersion(userById.getVersion() + 1);

        User updatedUser = userRepository.save(userById);

        return ResponseEntity.ok(updatedUser);
    }

    public ResponseEntity<Void> deleteUser(String id) {
        User user = userRepository.findByUserId(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User with id " + id + " not found"));
        userRepository.delete(user);
        return ResponseEntity.noContent().build();
    }

    //ไว้สำหรับmap ส่วนไหนnull ก็ไม่ต้องแก้ไข ถ้าส่วนไหนไม่null จะต้องแก้ไข ยกเว้นพวก boolean หรือ enum จะต้องมา set เอง
    public static String[] getNullPropertyNames(Object source) {
        final BeanWrapper src = new BeanWrapperImpl(source);
        java.beans.PropertyDescriptor[] pds = src.getPropertyDescriptors();

        Set<String> emptyNames = new HashSet<>();
        for (java.beans.PropertyDescriptor pd : pds) {
            Object srcValue = src.getPropertyValue(pd.getName());
            if (srcValue == null) emptyNames.add(pd.getName());
        }

        String[] result = new String[emptyNames.size()];
        return emptyNames.toArray(result);
    }

    public ResponseEntity<PreferenceUserDTO> UserPreferenceById(String id) {
        // 1. หา user
        User user = userRepository.findByUserId(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        PreferenceUserDTO pref = new PreferenceUserDTO();

        // 2. ดึง interests
        List<Integer> interests = userHasInterestRepository.findAllByUser_UserId(user.getUserId())
                .stream()
                .map(uhi -> uhi.getInterestInterest().getId())
                .toList();
        pref.setInterests(interests);

        // 3. ดึง tags
        List<Integer> tags = userHasTagRepository.findAllByUser_UserId(user.getUserId())
                .stream()
                .map(uht -> uht.getTagTag().getId())
                .toList();
        pref.setTags(tags);

        // 4. ดึง lifestyles
        List<Integer> lifeStyles = userHasLifestyleRepository.findAllByUser_UserId(user.getUserId())
                .stream()
                .map(uhl -> uhl.getLifestyleLifestyle().getId())
                .toList();
        pref.setLifeStyles(lifeStyles);

        // 5. ดึง travel styles
        List<Integer> travelStyles = userHasTravelstyleRepository.findAllByUser_UserId(user.getUserId())
                .stream()
                .map(uht -> uht.getTravelstyleTravel().getId())
                .toList();
        pref.setTravelStyles(travelStyles);

        return ResponseEntity.ok(pref);
    }

    @Transactional
    public ResponseEntity<PreferenceUserDTO> createUserPreference(String accessToken, PreferenceUserDTO pref) {
        String token = accessToken.substring(7);
        DecodedJWT jwt = JWT.decode(token);
        String sub = jwt.getClaim("sub").asString();

        User user = (sub.length() == 10)
                ? userRepository.findByPhoneNumber(sub).orElseThrow()
                : userRepository.findByEmail(sub).orElseThrow();

        // 2. Save interests
        saveManyToMany(
                user,
                pref.getInterests(),
                userHasInterestRepository,
                interestRepository,
                (u, interest) -> {
                    UserHasInterestId id = new UserHasInterestId();
                    id.setUserId(u.getUserId());
                    id.setInterestInterestid(interest.getId());

                    UserHasInterest join = new UserHasInterest();
                    join.setId(id);
                    join.setUser(u);
                    join.setInterestInterest(interest);
                    return join;
                },
                userHasInterestRepository::deleteAllByUser
        );

        // 3. Save tags
        saveManyToMany(
                user,
                pref.getTags(),
                userHasTagRepository,
                tagRepository,
                (u, tag) -> {
                    UserHasTagId id = new UserHasTagId();
                    id.setUserId(u.getUserId());
                    id.setTagTagid(tag.getId());

                    UserHasTag join = new UserHasTag();
                    join.setId(id);
                    join.setUser(u);
                    join.setTagTag(tag);
                    return join;
                },
                userHasTagRepository::deleteAllByUser
        );

        // 4. Save lifestyles
        saveManyToMany(
                user,
                pref.getLifeStyles(),
                userHasLifestyleRepository,
                lifeStyleRepository,
                (u, lifestyle) -> {
                    UserHasLifestyleId id = new UserHasLifestyleId();
                    id.setUserId(u.getUserId());
                    id.setLifestyleLifestyleid(lifestyle.getId());

                    UserHasLifestyle join = new UserHasLifestyle();
                    join.setId(id);
                    join.setUser(u);
                    join.setLifestyleLifestyle(lifestyle);
                    return join;
                },
                userHasLifestyleRepository::deleteAllByUser
        );

        // 5. Save travel styles
        saveManyToMany(
                user,
                pref.getTravelStyles(),
                userHasTravelstyleRepository,
                travelStyleRepository,
                (u, travel) -> {
                    UserHasTravelstyleId id = new UserHasTravelstyleId();
                    id.setUserId(u.getUserId());
                    id.setTravelstyleTravelid(travel.getId());

                    UserHasTravelstyle join = new UserHasTravelstyle();
                    join.setId(id);
                    join.setUser(u);
                    join.setTravelstyleTravel(travel);
                    return join;
                },
                userHasTravelstyleRepository::deleteAllByUser
        );

        return ResponseEntity.ok(pref);
    }

    public ResponseEntity<PreferenceMatchUserDTO> createUserPreferenceMatch(String accessToken, PreferenceMatchUserDTO pref) {
        String token = accessToken.substring(7);
        DecodedJWT jwt = JWT.decode(token);
        String sub = jwt.getClaim("sub").asString();

        User user = (sub.length() == 10)
                ? userRepository.findByPhoneNumber(sub).orElseThrow()
                : userRepository.findByEmail(sub).orElseThrow();

        PreferenceMatch preferenceMatch = new PreferenceMatch();

        if (pref.getInterestedGender() != null) {
            preferenceMatch.setInterestedGender(PreferenceGender.valueOf(pref.getInterestedGender()));
        }
        if (pref.getInterestedInterest() != null) {
            preferenceMatch.setInterestedInterest(PreferenceLevel.valueOf(pref.getInterestedInterest()));
        }
        if (pref.getInterestedLifeStyle() != null) {
            preferenceMatch.setInterestedLifeStyle(PreferenceLevel.valueOf(pref.getInterestedLifeStyle()));
        }
        if (pref.getInterestedTravelStyle() != null) {
            preferenceMatch.setInterestedTravelStyle(PreferenceLevel.valueOf(pref.getInterestedTravelStyle()));
        }
        preferenceMatch.setUser(user);
        preferenceMatch.setInterestedAgeMax(pref.getInterestedAgeMax());
        preferenceMatch.setInterestedAgeMin(pref.getInterestedAgeMin());
        preferenceMatch.setInterestedDistanceMin(pref.getInterestedDistanceMin());
        preferenceMatch.setInterestedDistanceMax(pref.getInterestedDistanceMax());

        preferenceMatchRepository.save(preferenceMatch);

        return ResponseEntity.ok(pref);
    }

    private <E, M> void saveManyToMany(
            User user,
            List<Integer> ids,
            JpaRepository<E, ?> joinRepo,
            JpaRepository<M, Integer> mainRepo,
            BiFunction<User, M, E> creator,
            Consumer<User> deleteOld
    ) {
        // ลบของเก่า
        deleteOld.accept(user);

        // insert ของใหม่
        for (Integer id : ids) {
            M mainEntity = mainRepo.findById(id)
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.NOT_FOUND, "ID not found: " + id));

            E joinEntity = creator.apply(user, mainEntity);

            joinRepo.save(joinEntity);
        }
    }

    public PreferenceUserProfileDTO getUserProfile(String id) {
        // ดึง entity จาก DB
        List<UserHasInterest> userHasInterest = userHasInterestRepository.findAllByUser_UserId(id);
        List<UserHasLifestyle> userHasLifestyles = userHasLifestyleRepository.findAllByUser_UserId(id);
        List<UserHasTravelstyle> userHasTravelstyles = userHasTravelstyleRepository.findAllByUser_UserId(id);
        List<UserHasTag> userHasTags = userHasTagRepository.findAllByUser_UserId(id);
        String userPhotos = userPhotoRepository.findAttributesJsonByUser_UserId(id);
        PreferenceMatch preferenceMatch = preferenceMatchRepository.findPreferenceMatchByUser_UserId(id);

        PreferenceUserProfileDTO dto = new PreferenceUserProfileDTO();

        // เพศที่สนใจ
        dto.setInterestedGender(preferenceMatch.getInterestedGender().toString());

        // แปลง entity เป็น List<Integer> ของ id
        dto.setInterests(
                userHasInterest.stream()
                        .map(uhi -> uhi.getInterestInterest().getId())
                        .toList()
        );

        dto.setLifeStyles(
                userHasLifestyles.stream()
                        .map(uhl -> uhl.getLifestyleLifestyle().getId()) // สมมติ entity มี getLifeStyleId()
                        .toList()
        );

        dto.setTags(
                userHasTags.stream()
                        .map(uht -> uht.getTagTag().getId()) // สมมติ entity มี getTagId()
                        .toList()
        );

        dto.setTravelStyles(
                userHasTravelstyles.stream()
                        .map(uhts -> uhts.getTravelstyleTravel().getId()) // สมมติ entity มี getTravelStyleId()
                        .toList()
        );

        // รูปภาพ
        dto.setPhotos(userPhotos);

        return dto;
    }


}
