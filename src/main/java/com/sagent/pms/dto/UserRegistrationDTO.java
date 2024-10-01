package com.sagent.pms.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserRegistrationDTO {
    private String name;
    private String email;
    private String password;
    private String phoneNumber;
    private Set<Integer> roleIDs;  // Role IDs to be assigned to the user
}
