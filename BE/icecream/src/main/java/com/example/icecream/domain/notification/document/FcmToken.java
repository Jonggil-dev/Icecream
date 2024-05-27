package com.example.icecream.domain.notification.document;

import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.mapping.MongoId;

import java.time.LocalDateTime;

@Document(collection = "fcm_token")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class FcmToken {

    @MongoId
    private String id;

    @Field(name = "user_id")
    @NotNull
    private int userId;

    @Field(name = "token")
    @NotNull
    private String token;

    @Field(name = "created_at")
    @CreatedDate
    @NotNull
    private LocalDateTime createdAt;

    @Field(name = "updated_at")
    @LastModifiedDate
    @NotNull
    private LocalDateTime updatedAt;

    public void updateToken(String token) {
        this.token = token;
    }
}
