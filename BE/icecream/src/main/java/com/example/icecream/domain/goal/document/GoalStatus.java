package com.example.icecream.domain.goal.document;

import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.mapping.MongoId;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Document(collection = "goal_status")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class GoalStatus {

    @MongoId
    private String id;

    @Field(name = "user_id")
    private int userId;

    @Field(name = "result")
    private Map<LocalDate, Integer> result;

    @Field(name = "created_at")
    @CreatedDate
    private LocalDateTime createdAt;

    @Field(name = "updated_at")
    @LastModifiedDate
    private LocalDateTime updatedAt;

    public void updateGoalStatus(LocalDate date, Integer status) {
        this.result.put(date, status);
        this.updatedAt = LocalDateTime.now();
    }
}
