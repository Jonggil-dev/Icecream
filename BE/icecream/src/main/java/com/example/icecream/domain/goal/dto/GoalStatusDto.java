package com.example.icecream.domain.goal.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.Map;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GoalStatusDto {

    @NotNull
    private Map<LocalDate, Integer> goalStatusMap;
}
