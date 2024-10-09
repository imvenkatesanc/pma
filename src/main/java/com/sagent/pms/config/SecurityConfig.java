package com.sagent.pms.config;

import com.sagent.pms.models.AppUser;
import com.sagent.pms.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

import java.util.List;
import java.util.stream.Collectors;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private UserRepository userRepository;

    @Bean
    public SecurityFilterChain appSecurityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(authz -> authz
                        .requestMatchers("/auth/register", "/auth/login").permitAll() // Ensure these endpoints are accessible
                        .requestMatchers("/api/properties").hasRole("LANDLORD")
                        .requestMatchers("/api/**").hasRole("CLIENT")
                        .requestMatchers("/api/properties").hasAnyRole("LANDLORD", "CLIENT")
                        .requestMatchers("/api/properties/**").hasRole("LANDLORD")
                        .anyRequest().authenticated()
                );
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(HttpSecurity http) throws Exception {
        AuthenticationManagerBuilder authManagerBuilder = http.getSharedObject(AuthenticationManagerBuilder.class);
        authManagerBuilder.userDetailsService(userDetailsService()).passwordEncoder(passwordEncoder());
        return authManagerBuilder.build();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        return username -> {
            AppUser appUser = userRepository.findByEmail(username);
            if (appUser != null) {
                List<GrantedAuthority> authorities = appUser.getRoles().stream()
                        .map(role -> new SimpleGrantedAuthority("ROLE_" + role.getName().toUpperCase()))
                        .collect(Collectors.toList());

                return org.springframework.security.core.userdetails.User.withUsername(appUser.getEmail())
                        .password(appUser.getPassword())
                        .authorities(authorities)
                        .build();
            } else {
                throw new UsernameNotFoundException("User not found");
            }
        };
    }
}
