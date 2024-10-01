package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;

@Data
@Entity
@Table(name = "Landlord")
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
