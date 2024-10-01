package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Entity
@Table(name = "PropertyType")
public class PropertyType {
    @Getter
    @Setter
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer propertyTypeId;

    @Column(nullable = false)
    private String typeName;

}
