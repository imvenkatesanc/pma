package com.sagent.pms.service;
import com.sagent.pms.models.Rating;
import com.sagent.pms.repository.RatingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class RatingService {
    @Autowired
    private RatingRepository ratingRepository;

    public List<Rating> getAllRatings() {
        return ratingRepository.findAll();
    }

    public List<Rating> getRatingsByPropertyId(Long propertyId) {
        return ratingRepository.findByPropertyId(propertyId);
    }

    public Rating createRating(Rating rating) {
        return ratingRepository.save(rating);
    }

    public Rating updateRating(Long id, Rating rating) {
        Rating existingRating = ratingRepository.findById(id).orElse(null);
        if (existingRating != null) {
            rating.setId(id);
            return ratingRepository.save(rating);
        }
        return null;
    }

    public void deleteRating(Long id) {
        ratingRepository.deleteById(id);
    }
}
