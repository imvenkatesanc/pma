package com.sagent.pms.models;

import lombok.Data;
import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "properties")
@Data
public class Property {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String type;
    private String address;
    private String description;

    @Column(precision = 10, scale = 2)
    private BigDecimal price;

    @Lob // Use @Lob for large objects
    private byte[] image;

    private boolean isAvailable; // Add availability field
}
