package sit.chat2date.cp25ssi2.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import sit.chat2date.cp25ssi2.entities.User;
import sit.chat2date.cp25ssi2.repositories.UserRepository;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;


    public ResponseEntity<Void> deleteUser(Integer id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User with id " + id + " not found"));
        userRepository.delete(user);
        return ResponseEntity.noContent().build();
    }


}
