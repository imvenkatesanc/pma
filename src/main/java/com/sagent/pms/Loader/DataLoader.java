package com.sagent.pms.Loader;

import com.sagent.pms.Model.Role;
import com.sagent.pms.Repository.RoleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataLoader implements CommandLineRunner {

    @Autowired
    private RoleRepository roleRepository;

    @Override
    public void run(String... args) throws Exception {
        if (roleRepository.count() == 0) { // Check if roles already exist
            Role landlord = new Role();
            landlord.setName("landlord"); // Update method name
            roleRepository.save(landlord);

            Role client = new Role();
            client.setName("client"); // Update method name
            roleRepository.save(client);
        }
    }
}

