package com.sagent.pms.services;

import com.sagent.pms.models.AppUser;
import com.sagent.pms.models.Role;
import com.sagent.pms.repository.UserRepository;
import com.sagent.pms.repository.RoleRepository;
import com.sagent.pms.security.JwtUtil;
import com.sagent.pms.payload.LoginResponseDTO;
import com.sagent.pms.payload.UserDTO;
import com.sagent.pms.payload.UserRegistrationDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Set;

@Service
public class AuthService implements UserDetailsService {

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
    public LoginResponseDTO login(String email, String password) {
        AppUser appUser = userRepository.findByEmail(email);
        if (appUser == null || !passwordEncoder.matches(password, appUser.getPassword())) {
            throw new InvalidCredentialsException("Invalid email or password");
        }

        String token = jwtUtil.generateToken(appUser);
        UserDTO userDTO = appUser.toUserDTO();
        return new LoginResponseDTO(token, userDTO);
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        AppUser appUser = userRepository.findByEmail(email);
        if (appUser == null) {
            throw new UsernameNotFoundException("User not found");
        }
        return new org.springframework.security.core.userdetails.User(appUser.getEmail(), appUser.getPassword(), getAuthorities(appUser.getRoles()));
    }

    private Set<org.springframework.security.core.GrantedAuthority> getAuthorities(Set<Role> roles) {
        Set<org.springframework.security.core.GrantedAuthority> authorities = new HashSet<>();
        for (Role role : roles) {
            authorities.add(new org.springframework.security.core.authority.SimpleGrantedAuthority(role.getName()));
        }
        return authorities;
    }

    public static class InvalidCredentialsException extends RuntimeException {
        public InvalidCredentialsException(String message) {
            super(message);
        }
    }
}
