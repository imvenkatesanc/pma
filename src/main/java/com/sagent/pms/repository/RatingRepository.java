package com.sagent.pms.repository;

import com.sagent.pms.models.Rating;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RatingRepository extends JpaRepository<Rating, Long> {
    List<Rating> findByPropertyId(Long propertyId); // Fetch ratings by property ID
}
