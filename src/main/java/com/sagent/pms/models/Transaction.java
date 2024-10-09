package com.sagent.pms.models;

import jakarta.persistence.*;
import lombok.Data;

import java.util.Date;

@Data
@Entity
@Table(name = "transactions")
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long landlordId; // Reference to the landlord
    private Long clientId;   // Reference to the client
    private Double amount;   // Transaction amount
    private Date transactionDate; // Date of transaction
    private String status;   // Transaction status
}
