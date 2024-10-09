package com.sagent.pms.repository;

import com.sagent.pms.models.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<AppUser, Integer> {
    AppUser findByEmail(String email);
}