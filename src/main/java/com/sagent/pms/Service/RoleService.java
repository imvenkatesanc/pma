package com.sagent.pms.Service;

import com.sagent.pms.Model.Role;
import com.sagent.pms.Repository.RoleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RoleService {
    @Autowired
    private RoleRepository roleRepository;

    public List<Role> getAllRoles() {
        return roleRepository.findAll();
    }

    public Role createRole(Role role) {
        return roleRepository.save(role);
    }

    public Role getRoleById(int id) {
        return roleRepository.findById(id).orElse(null);
    }

    public void deleteRole(int id) {
        roleRepository.deleteById(id);
    }
}
