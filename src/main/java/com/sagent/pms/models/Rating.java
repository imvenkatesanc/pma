package com.sagent.pms.models;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "ratings")
public class Rating {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long propertyId; // Reference to the property being rated
    private Integer rating;   // Rating value (e.g., 1 to 5)
    private String comment;   // Optional comment
}
