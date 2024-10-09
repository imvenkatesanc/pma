package com.sagent.pms.models;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "Client")
public class Client {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer clientId;

    @OneToOne
    @JoinColumn(name = "user_id")
    private AppUser user;
}
