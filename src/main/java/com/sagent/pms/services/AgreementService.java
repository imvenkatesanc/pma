package com.sagent.pms.services;

import com.sagent.pms.models.Agreement;
import com.sagent.pms.repository.AgreementRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AgreementService {
    @Autowired
    private AgreementRepository agreementRepository;

    public List<Agreement> getAllAgreements() {
        return agreementRepository.findAll();
    }

    public Agreement getAgreementById(Long id) {
        return agreementRepository.findById(id).orElse(null);
    }

    public Agreement createAgreement(Agreement agreement) {
        return agreementRepository.save(agreement);
    }

    public Agreement updateAgreement(Long id, Agreement agreement) {
        Agreement existingAgreement = getAgreementById(id);
        if (existingAgreement != null) {
            agreement.setId(id);
            return agreementRepository.save(agreement);
        }
        return null;
    }

    public void deleteAgreement(Long id) {
        agreementRepository.deleteById(id);
    }
}
