package com.dailycodebuffer.filemngt.service;

import com.dailycodebuffer.filemngt.entity.Attachment;
import com.dailycodebuffer.filemngt.repository.AttachmentRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.util.Objects;

@Service
public class AttachmentServiceImpl implements AttachmentService{

    private AttachmentRepository attachmentRepository;

    public AttachmentServiceImpl(AttachmentRepository attachmentRepository) {
        this.attachmentRepository = attachmentRepository;
    }

    @Override
    public Attachment saveAttachment(MultipartFile file) throws Exception {
        String fileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));

        // Check for invalid path sequence
        if (fileName.contains("..")) {
            throw new Exception("Filename contains invalid path sequence: " + fileName);
        }

        try {
            // Check if the file is empty
            if (file.isEmpty()) {
                throw new Exception("Cannot save empty file: " + fileName);
            }
            // Check the size limit (e.g., 10 MB)
            else if (file.getSize() > 10 * 1024 * 1024) {
                throw new Exception("File is too large: " + fileName);
            }

            // Create the attachment object
            Attachment attachment = new Attachment(fileName, file.getContentType(), file.getBytes());

            // Save to the repository
            return attachmentRepository.save(attachment);
        } catch (DataIntegrityViolationException e) {
            // Log specific details about the exception
            throw new Exception("Could not save File due to integrity violation: " + fileName, e);
        } catch (Exception e) {
            // Log any other exceptions
            throw new Exception("Could not save File: " + fileName, e);
        }
    }


    @Override
    public Attachment getAttachment(String fileId) throws Exception {
        return attachmentRepository
                .findById(fileId)
                .orElseThrow(
                        () -> new Exception("File not found with Id: " + fileId));
    }
}
