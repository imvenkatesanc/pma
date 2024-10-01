package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.Data;
import java.util.Set;

@Entity
@Data
@Table(name = "app_user") // Avoid "user" keyword conflict in SQL
public class AppUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer userID;

    private String name;
    private String email;
    private String password;
    private String phoneNumber;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "user_roles", // Junction table
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles; // Assign roles during registration

    // Method to get the first role ID (if assuming one role per user)
    public Integer getRoleId() {
        // Return null if roles are not assigned
        if (roles == null || roles.isEmpty()) {
            return null;
        }
        // Get the first role's ID
        return roles.iterator().next().getRoleId(); // Assuming Role has a method getRoleId()
    }
}
