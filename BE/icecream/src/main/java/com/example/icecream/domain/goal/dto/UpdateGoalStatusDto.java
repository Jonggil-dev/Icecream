package com.example.icecream.domain.goal.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateGoalStatusDto {

    @NotNull(message = "user_id is required")
    private Integer userId;

    @NotNull(message = "date is required")
    private LocalDate date;

    @NotNull(message = "status is required")
    private Integer status;
}
