package com.sagent.pms.Model;

import jakarta.persistence.*;
import lombok.*;

@Data
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "PropertyAddress")
public class PropertyAddress {
    @Getter
    @Setter
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer addressId;
    private String streetName;
    private String city;
    private String state;
    private String zipCode;

    public String getStreet() {
        return streetName;
    }
}
