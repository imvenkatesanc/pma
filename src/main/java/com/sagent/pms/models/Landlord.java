package com.sagent.pms.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;

@Entity
@Table(name = "Landlord")
@Data
public class Landlord {

    @Getter
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer landlordId;

    @OneToOne
    @JoinColumn(name = "user_id")
    private AppUser user;

    public String getName() {
        return user.getEmail();
    }
}
