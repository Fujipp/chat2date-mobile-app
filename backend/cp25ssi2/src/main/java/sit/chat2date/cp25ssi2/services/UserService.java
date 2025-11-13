package sit.chat2date.cp25ssi2.services;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.BeanWrapperImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.enums.AccountStatus;
import sit.chat2date.cp25ssi2.enums.Provider;
import sit.chat2date.cp25ssi2.enums.Role;
import sit.chat2date.cp25ssi2.enums.Sex;
import sit.chat2date.cp25ssi2.exceptions.NotFoundException;
import sit.chat2date.cp25ssi2.exceptions.PreconditionFailedException;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public User createUser(User user) {
        return userRepository.save(user);
    }

    public ResponseEntity<User> updateUserById(String id, @RequestBody User user) {
        User userById = userRepository.findByUserId(id).orElseThrow(() -> new NotFoundException("User id: "+ id +" not found"));
        if (!user.getVersion().equals(userById.getVersion())) {
            throw new PreconditionFailedException("version", "mismatch");
        }
        BeanUtils.copyProperties(user, userById, getNullPropertyNames(user));
        if (user.getFaceVerify() != null) {
            userById.setFaceVerify(user.getFaceVerify());
        }
        if (user.getIsBlacklist() != null) {
            userById.setIsBlacklist(user.getIsBlacklist());
        }
        if (user.getIsVerify() != null) {
            userById.setIsVerify(user.getIsVerify());
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

}
