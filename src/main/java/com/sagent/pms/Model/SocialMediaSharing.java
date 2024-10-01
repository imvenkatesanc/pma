package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "SocialMediaSharing")
public class SocialMediaSharing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer shareId;

    @ManyToOne
    @JoinColumn(name = "property_id")
    private Property property;

    private String platform;

    private Integer shareCount;
}
