package com.example.icecream.domain.notification.document;

import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.mapping.MongoId;

import java.time.LocalDateTime;

@Document(collection = "notification_list")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class NotificationList {

    @MongoId
    private String id;

    @Field(name = "user_id")
    @NotNull
    private int userId;

    @Field(name = "content")
    @NotNull
    private String content;

    @Field(name = "created_at")
    @CreatedDate
    @NotNull
    private LocalDateTime createdAt;

    @Field(name = "updated_at")
    @LastModifiedDate
    @NotNull
    private LocalDateTime updatedAt;
}
