package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Entity
@Table(name = "Properties")
public class Property {
    @Getter
    @Setter
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer propertyId;

    @ManyToOne
    @JoinColumn(name = "address_id")
    private PropertyAddress address;

    private String description;

    private Double price;

    @ManyToOne
    @JoinColumn(name = "property_type_id")
    private PropertyType propertyType;

    private String status;

    private Integer size;

    @ManyToOne
    @JoinColumn(name = "landlord_id")
    private Landlord landlord;


}
