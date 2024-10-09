package com.sagent.pms.controllers;

import com.sagent.pms.models.Agreement;
import com.sagent.pms.services.AgreementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/agreements")
public class AgreementController {
    @Autowired
    private AgreementService agreementService;

    @GetMapping
    public List<Agreement> getAllAgreements() {
        return agreementService.getAllAgreements();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Agreement> getAgreementById(@PathVariable Long id) {
        Agreement agreement = agreementService.getAgreementById(id);
        return agreement != null ? ResponseEntity.ok(agreement) : ResponseEntity.notFound().build();
    }

    @PostMapping
    public ResponseEntity<Agreement> createAgreement(@RequestBody Agreement agreement) {
        Agreement createdAgreement = agreementService.createAgreement(agreement);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdAgreement);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Agreement> updateAgreement(@PathVariable Long id, @RequestBody Agreement agreement) {
        Agreement updatedAgreement = agreementService.updateAgreement(id, agreement);
        return updatedAgreement != null ? ResponseEntity.ok(updatedAgreement) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAgreement(@PathVariable Long id) {
        agreementService.deleteAgreement(id);
        return ResponseEntity.noContent().build();
    }
}
