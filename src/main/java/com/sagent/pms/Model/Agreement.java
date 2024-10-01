package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "Agreement")
public class Agreement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer agreementId;

    private java.sql.Date startDate;

    private java.sql.Date endDate;

    private Double amount;

    private String documentPath;

    @ManyToOne
    @JoinColumn(name = "client_id")
    private Client client;

    @ManyToOne
    @JoinColumn(name = "property_id")
    private Property property;

    @ManyToOne
    @JoinColumn(name = "landlord_id")
    private Landlord landlord;

    @OneToOne
    @JoinColumn(name = "transaction_id")
    private Transaction transaction;
}
