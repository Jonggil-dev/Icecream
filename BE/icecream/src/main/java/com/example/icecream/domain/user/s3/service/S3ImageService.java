package com.example.icecream.domain.user.s3.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.util.IOUtils;

import java.io.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

import com.example.icecream.common.exception.BadRequestException;
import com.example.icecream.common.exception.InternalServerException;
import com.example.icecream.common.exception.NotFoundException;
import com.example.icecream.domain.user.entity.User;
import com.example.icecream.domain.user.error.UserErrorCode;
import com.example.icecream.domain.user.repository.UserRepository;
import com.example.icecream.domain.user.s3.error.S3ErrorCode;
import com.example.icecream.domain.user.util.UserValidationUtils;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@RequiredArgsConstructor
@Component
public class S3ImageService {

    private final AmazonS3 amazonS3;
    private final UserRepository userRepository;
    private final UserValidationUtils userValidationUtils;

    @Value("${cloud.aws.s3.bucketName}")
    private String bucketName;

    @Transactional
    public String uploadImage(MultipartFile image, int userId, int parentId) {
        User user = userValidationUtils.isValidUser(userId);

        if(!user.getIsParent()){
            userValidationUtils.isValidChild(parentId, userId);
        }

        if(image.isEmpty() || Objects.isNull(image.getOriginalFilename())){
            throw new BadRequestException(S3ErrorCode.Image_NOT_FOUND.getMessage());
        }

        this.validateImageFileExtention(image.getOriginalFilename());

        String newImageUrl = null;

        try {
            newImageUrl = this.uploadImageToS3(image);
            deleteImageFromS3(userId, null);
            user.updateProfileImage(newImageUrl);
            userRepository.save(user);
            return newImageUrl;
        } catch (InternalServerException e) {
            if (newImageUrl != null) {
                try {
                    amazonS3.deleteObject(new DeleteObjectRequest(bucketName, newImageUrl));
                } catch (Exception s3Exception) {
                    throw new InternalServerException(S3ErrorCode.UPLOAD_ROLLBACK_ERROR.getMessage());
                }
            }
            throw e;
        } catch (Exception e) {
            throw new InternalServerException(S3ErrorCode.EXCEPTION_ON_IMAGE_UPLOAD.getMessage());
        }
    }


    private String uploadImageToS3(MultipartFile image) throws IOException {
        String originalFilename = image.getOriginalFilename();
        String extention = Objects.requireNonNull(originalFilename).substring(originalFilename.lastIndexOf(".") + 1);
        String s3FileName = UUID.randomUUID().toString().substring(0, 10) + originalFilename;
        InputStream is = image.getInputStream();
        byte[] bytes = IOUtils.toByteArray(is);
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentType("image/" + extention);
        metadata.setContentLength(bytes.length);
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bytes);

        try{
            PutObjectRequest putObjectRequest =
                    new PutObjectRequest(bucketName, s3FileName, byteArrayInputStream, metadata)
                            .withCannedAcl(CannedAccessControlList.PublicRead);
            amazonS3.putObject(putObjectRequest);
        }catch (Exception e){
            throw new InternalServerException(S3ErrorCode.PUT_OBJECT_EXCEPTION.getMessage());
        }finally {
            byteArrayInputStream.close();
            is.close();
        }

        return amazonS3.getUrl(bucketName, s3FileName).toString();
    }

    public void deleteImageFromS3(int userId, Integer parentId){
        User user = userValidationUtils.isValidUser(userId);

        if(!user.getIsParent() && parentId != null){
            userValidationUtils.isValidChild(parentId, userId);
        }

        Optional.ofNullable(user.getProfileImage()).ifPresent(profileImage -> {
            String key = getKeyFromImageAddress(profileImage);
            try {
                amazonS3.deleteObject(new DeleteObjectRequest(bucketName, key));
            } catch (Exception e) {
                throw new InternalServerException(S3ErrorCode.IO_EXCEPTION_ON_IMAGE_DELETE.getMessage());
            }
        });
    }

    private String getKeyFromImageAddress(String imageAddress){
        try{
            URL url = new URL(imageAddress);
            String decodingKey = URLDecoder.decode(url.getPath(), StandardCharsets.UTF_8);
            return decodingKey.substring(1); // 맨 앞의 '/' 제거
        }catch (MalformedURLException e){
            throw new InternalServerException(S3ErrorCode.IO_EXCEPTION_ON_IMAGE_DELETE.getMessage());
        }
    }

    private void validateImageFileExtention(String filename) {
        int lastDotIndex = filename.lastIndexOf(".");
        if (lastDotIndex == -1) {
            throw new BadRequestException(S3ErrorCode.NO_FILE_EXTENTION.getMessage());
        }

        String extention = filename.substring(lastDotIndex + 1).toLowerCase();
        List<String> allowedExtentionList = Arrays.asList("jpg", "jpeg", "png", "gif");

        if (!allowedExtentionList.contains(extention)) {
            throw new BadRequestException(S3ErrorCode.INVALID_FILE_EXTENTION.getMessage());
        }
    }
}