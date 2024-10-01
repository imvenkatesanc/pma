package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "Ratings")
public class Ratings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer ratingId;

    @ManyToOne
    @JoinColumn(name = "property_id")
    private Property property;

    private Integer rating;

    private String comment;
}
