package com.sagent.pms.payload;

import lombok.Data;
import java.util.Set;

@Data
public class UserRegistrationDTO {
    private String name;
    private String email;
    private String password;
    private String phoneNumber;
    private Set<Integer> roleIDs; // Role IDs to be assigned to the user
}