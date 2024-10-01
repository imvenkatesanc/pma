package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.Data;

import java.util.Date;

@Data
@Entity
@Table(name = "LandlordHistory")
public class LandlordHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer historyId;

    @ManyToOne
    @JoinColumn(name = "landlord_id")
    private Landlord landlord;

    private String description;

    private Date date;
}
