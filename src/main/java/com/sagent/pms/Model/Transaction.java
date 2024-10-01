package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.Data;

import java.util.Date;

@Data
@Entity
@Table(name = "[Transaction]")
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer transactionId;

    private Double amount;

    private Date transactionDate;

    @ManyToOne
    @JoinColumn(name = "landlord_id")
    private Landlord landlord;

    private String status;
}
