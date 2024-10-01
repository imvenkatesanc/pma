package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer roleID;

    private String name; // Role name, e.g., "landlord" or "client"

    public Integer getRoleId() {
        return roleID;
    }
}