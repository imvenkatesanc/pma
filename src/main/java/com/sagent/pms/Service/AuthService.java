package com.sagent.pms.Service;

import com.sagent.pms.Model.AppUser;
import com.sagent.pms.Model.Role;
import com.sagent.pms.Repository.UserRepository;
import com.sagent.pms.Repository.RoleRepository;
import com.sagent.pms.Security.JwtUtil;
import com.sagent.pms.dto.LoginResponseDTO;
import com.sagent.pms.dto.UserDTO;
import com.sagent.pms.dto.UserRegistrationDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Set;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private JwtUtil jwtUtil;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // Register a new user
    public AppUser register(UserRegistrationDTO registrationDTO) {
        if (userRepository.findByEmail(registrationDTO.getEmail()) != null) {
            throw new RuntimeException("Email already in use");
        }

        AppUser appUser = new AppUser();
        appUser.setName(registrationDTO.getName());
        appUser.setEmail(registrationDTO.getEmail());
        appUser.setPassword(passwordEncoder.encode(registrationDTO.getPassword()));
        appUser.setPhoneNumber(registrationDTO.getPhoneNumber());

        // Fetch roles by their IDs
        Set<Role> roles = new HashSet<>(roleRepository.findAllById(registrationDTO.getRoleIDs()));
        appUser.setRoles(roles);

        return userRepository.save(appUser);
    }

    // Login a user and return a JWT token
//    public String login(String email, String password) {
//        AppUser appUser = userRepository.findByEmail(email);
//        if (appUser != null && passwordEncoder.matches(password, appUser.getPassword())) {
//            return jwtUtil.generateToken(appUser);
//        }
//        throw new InvalidCredentialsException("Invalid credentials");
//    }
    public LoginResponseDTO login(String email, String password) {
        AppUser appUser = userRepository.findByEmail(email);
        if (appUser != null && passwordEncoder.matches(password, appUser.getPassword())) {
            String token = jwtUtil.generateToken(appUser);
            UserDTO userDTO = appUser.toUserDTO();
            return new LoginResponseDTO(token, userDTO);
        }
        throw new InvalidCredentialsException("Invalid credentials");
    }

    public static class InvalidCredentialsException extends RuntimeException {
        public InvalidCredentialsException(String message) {
            super(message);
        }
    }
}

