// New class for RoleDTO
package com.sagent.pms.payload;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RoleDTO {
    private Integer roleID;
    private String name;
}