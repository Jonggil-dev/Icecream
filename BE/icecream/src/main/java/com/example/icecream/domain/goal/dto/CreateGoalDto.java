package com.example.icecream.domain.goal.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateGoalDto {

    @NotNull(message = "자녀가 선택되어있지 않습니다.")
    private Integer userId;
    @NotNull(message = "기간이 선택되어있지 않습니다.")
    private Integer period;
    @NotNull(message = "목표 내용이 작성되어있지 않습니다.")
    private String content;
}
