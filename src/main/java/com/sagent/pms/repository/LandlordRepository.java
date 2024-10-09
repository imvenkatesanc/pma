package com.sagent.pms.repository;

import com.sagent.pms.models.Landlord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LandlordRepository extends JpaRepository<Landlord, Long> {
    Optional<Landlord> findById(Long id);
}
