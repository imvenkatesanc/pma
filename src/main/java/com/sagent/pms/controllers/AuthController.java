package com.sagent.pms.controllers;

import com.sagent.pms.models.AppUser;
import com.sagent.pms.services.AuthService;
import com.sagent.pms.payload.LoginResponseDTO;
import com.sagent.pms.payload.LoginRequestDTO;
import com.sagent.pms.payload.UserRegistrationDTO;
import com.sagent.pms.Loader.exception.InvalidInputException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody UserRegistrationDTO userRegistrationDTO) {
        try {
            AppUser user = authService.register(userRegistrationDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body("Registration successful for user: " + user.getEmail());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Registration failed: " + e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> login(@RequestBody LoginRequestDTO loginRequestDTO) {
        // Validate input
        if (loginRequestDTO.getEmail() == null || loginRequestDTO.getEmail().isEmpty()) {
            throw new InvalidInputException("Email must not be empty");
        }
        if (loginRequestDTO.getPassword() == null || loginRequestDTO.getPassword().isEmpty()) {
            throw new InvalidInputException("Password must not be empty");
        }

        try {
            LoginResponseDTO response = authService.login(loginRequestDTO.getEmail(), loginRequestDTO.getPassword());
            return ResponseEntity.ok(response);
        } catch (AuthenticationException e) {
            System.err.println("Invalid credentials"); // Log error
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new LoginResponseDTO(null, null));
        }
    }
}
