package com.sagent.pms.repository;

import com.sagent.pms.models.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByLandlordId(Long landlordId); // Fetch transactions by landlord ID
}
