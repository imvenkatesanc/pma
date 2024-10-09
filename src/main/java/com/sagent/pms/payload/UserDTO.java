package com.sagent.pms.payload;

import lombok.Data;

import java.util.HashSet;
import java.util.Set;

@Data
public class UserDTO {
    private Integer userID;
    private String name;
    private String email;
    private String password;
    private String phoneNumber;
    private Set<RoleDTO> roles;

    public UserDTO() {
        this.roles = new HashSet<>(); // Initialize roles set
    }
}