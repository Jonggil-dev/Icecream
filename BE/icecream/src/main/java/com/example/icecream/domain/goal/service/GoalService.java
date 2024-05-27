package com.example.icecream.domain.goal.service;

import com.example.icecream.domain.goal.dto.CreateGoalDto;
import com.example.icecream.domain.goal.dto.GoalStatusDto;
import com.example.icecream.domain.goal.dto.UpdateGoalDto;
import com.example.icecream.domain.goal.dto.UpdateGoalStatusDto;
import com.example.icecream.domain.goal.entity.Goal;

import java.time.LocalDate;
import java.util.List;

public interface GoalService {

    void createGoal(CreateGoalDto createGoalDto, Integer parentId);
    void updateGoal(UpdateGoalDto updateGoalDto, Integer parentId);
    List<Goal> getGoals(int userId, Integer selfId);
    void createGoalStatus(int userId);
    GoalStatusDto getGoalStatus(int userId);
    void updateGoalStatus(UpdateGoalStatusDto updateGoalStatusDto, Integer parentId);
}
