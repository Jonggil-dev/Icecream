package com.example.icecream.domain.goal.controller;

import com.example.icecream.common.dto.ApiResponseDto;
import com.example.icecream.domain.goal.dto.CreateGoalDto;
import com.example.icecream.domain.goal.dto.GoalStatusDto;
import com.example.icecream.domain.goal.dto.UpdateGoalDto;
import com.example.icecream.domain.goal.dto.UpdateGoalStatusDto;
import com.example.icecream.domain.goal.entity.Goal;
import com.example.icecream.domain.goal.service.GoalService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class GoalController {

    private final GoalService goalService;

    @PostMapping("/goal")
    public ResponseEntity<ApiResponseDto<String>> createGoal(@Valid @RequestBody CreateGoalDto createGoalDto,
                                                             @AuthenticationPrincipal UserDetails userDetails) {
        goalService.createGoal(createGoalDto, Integer.parseInt(userDetails.getUsername()));
        return ApiResponseDto.success("목표를 설정하였습니다.", null);
    }

    @PatchMapping("/goal")
    public ResponseEntity<ApiResponseDto<String>> updateGoal(@Valid @RequestBody UpdateGoalDto updateGoalDto,
                                                             @AuthenticationPrincipal UserDetails userDetails) {
        goalService.updateGoal(updateGoalDto, Integer.parseInt(userDetails.getUsername()));
        return ApiResponseDto.success("목표를 수정하였습니다.", null);
    }

    @GetMapping("/goal")
    public ResponseEntity<ApiResponseDto<List<Goal>>> getGoal(@RequestParam(name = "user_id") int userId,
                                                              @AuthenticationPrincipal UserDetails userDetails) {
        List<Goal> goals = goalService.getGoals(userId, Integer.parseInt(userDetails.getUsername()));
        return ApiResponseDto.success("목표를 불러왔습니다.", goals);
    }

    @GetMapping("/goal/status")
    public ResponseEntity<ApiResponseDto<Map<LocalDate, Integer>>> getGoalStatus(
            @RequestParam("user_id") int userId) {
        GoalStatusDto goalStatus = goalService.getGoalStatus(userId);
        return ApiResponseDto.success("목표 상태를 불러왔습니다.", goalStatus.getGoalStatusMap());
    }

    @PatchMapping("/goal/status")
    public ResponseEntity<ApiResponseDto<String>> updateGoalStatus(@Valid @RequestBody UpdateGoalStatusDto updateGoalStatusDto,
                                                                   @AuthenticationPrincipal UserDetails userDetails) {
        goalService.updateGoalStatus(updateGoalStatusDto, Integer.parseInt(userDetails.getUsername()));
        return ApiResponseDto.success("목표 상태를 수정하였습니다.", null);
    }
}
