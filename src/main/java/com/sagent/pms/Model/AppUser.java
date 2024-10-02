package com.sagent.pms.Model;

import com.sagent.pms.dto.RoleDTO;
import com.sagent.pms.dto.UserDTO;
import jakarta.persistence.*;
import lombok.Data;

import java.util.HashSet;
import java.util.Set;

@Entity
@Data
@Table(name = "app_user")
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
            name = "user_roles",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles;

    public UserDTO toUserDTO() {
        UserDTO userDTO = new UserDTO();
        userDTO.setUserID(this.userID);
        userDTO.setName(this.name);
        userDTO.setEmail(this.email);
        userDTO.setPhoneNumber(this.phoneNumber);

        if (this.roles != null) { // Check if roles is not null
            Set<RoleDTO> roleDTOs = new HashSet<>();
            this.roles.forEach(role -> {
                RoleDTO roleDTO = new RoleDTO();
                roleDTO.setRoleID(role.getRoleID());
                roleDTO.setName(role.getName());
                roleDTOs.add(roleDTO);
            });
            userDTO.setRoles(roleDTOs);
        }

        return userDTO;
    }
}