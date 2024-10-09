package com.sagent.pms.models;

import jakarta.persistence.*;
import lombok.Data;

import java.util.Date;

@Data
@Entity
@Table(name = "agreements")
public class Agreement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long landlordId; // Reference to the Landlord
    private Long clientId;   // Reference to the Client

    private Date startDate;
    private Date endDate;
    private String terms;     // Agreement terms
    private String status;     // Status (e.g., ACTIVE, TERMINATED)
}
