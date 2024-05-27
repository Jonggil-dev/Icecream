package com.example.icecream.domain.goal.service;

import com.example.icecream.common.exception.BadRequestException;
import com.example.icecream.common.exception.DataAccessException;
import com.example.icecream.common.exception.DataConflictException;
import com.example.icecream.common.exception.NotFoundException;
import com.example.icecream.domain.goal.document.GoalStatus;
import com.example.icecream.domain.goal.dto.CreateGoalDto;
import com.example.icecream.domain.goal.dto.GoalStatusDto;
import com.example.icecream.domain.goal.dto.UpdateGoalDto;
import com.example.icecream.domain.goal.dto.UpdateGoalStatusDto;
import com.example.icecream.domain.goal.entity.Goal;
import com.example.icecream.domain.goal.error.GoalErrorCode;
import com.example.icecream.domain.goal.repository.mongodb.GoalStatusRepository;
import com.example.icecream.domain.goal.repository.postgres.GoalRepository;
import com.example.icecream.domain.user.util.UserValidationUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.Period;
import java.util.*;

@Service
public class GoalServiceImpl implements GoalService {

    private final GoalRepository goalRepository;
    private final GoalStatusRepository goalStatusRepository;
    private final UserValidationUtils userValidationUtils;

    public GoalServiceImpl(UserValidationUtils userValidationUtils,
                           GoalRepository goalRepository,
                           GoalStatusRepository goalStatusRepository) {
        this.goalRepository = goalRepository;
        this.goalStatusRepository = goalStatusRepository;
        this.userValidationUtils = userValidationUtils;
    }

    @Override
    @Transactional
    public void createGoal(CreateGoalDto createGoalDto, Integer parentId) {

        List<Goal> goals = goalRepository.findAllByUserId(createGoalDto.getUserId());
        boolean isActive = false;
        for (Goal goal : goals) {
            if (goal.getIsActive()) {
                isActive = true;
                break;
            }
        }
        if (!userValidationUtils.isParentUserWithPermission(parentId, createGoalDto.getUserId())) {
            throw new DataAccessException(GoalErrorCode.REGISTER_GOAL_ACCESS_DENIED.getMessage());
        } else if (isActive) {
            throw new DataConflictException(GoalErrorCode.REGISTER_GOAL_DUPLICATED.getMessage());
        }
        Goal goal = Goal.builder()
                .userId(createGoalDto.getUserId())
                .period(createGoalDto.getPeriod())
                .content(createGoalDto.getContent())
                .isActive(true)
                .build();

        goalRepository.save(goal);
    }

    @Override
    @Transactional
    public void updateGoal(UpdateGoalDto updateGoalDto, Integer parentId) {
        Goal goal = goalRepository.findById(updateGoalDto.getGoalId()).orElse(null);
        if (goal == null) {
            throw new NotFoundException(GoalErrorCode.NOT_FOUND_GOAL.getMessage());
        } else if (!userValidationUtils.isParentUserWithPermission(parentId, goal.getUserId())){
            throw new DataAccessException(GoalErrorCode.UPDATE_GOAL_ACCESS_DENIED.getMessage());
        } else if (!goal.getIsActive()) {
            throw new BadRequestException(GoalErrorCode.UPDATE_IS_NOT_ACTIVED_GOAL.getMessage());
        } else if (updateGoalDto.getPeriod() <= goal.getRecord()) {
            throw new BadRequestException(GoalErrorCode.UPDATE_GOAL_OVER_RECORD.getMessage());
        }
        goal.updateGoal(updateGoalDto.getPeriod(), updateGoalDto.getContent());
        goalRepository.save(goal);
    }

    @Override
    public List<Goal> getGoals(int userId, Integer selfId) {
        if (!userValidationUtils.isParentUserWithPermission(selfId, userId) && !selfId.equals(userId)) {
            throw new DataAccessException(GoalErrorCode.GET_GOAL_ACCESS_DENIED.getMessage());
        }
        return goalRepository.findAllByUserId(userId);
    }

    @Override
    @Transactional
    public void createGoalStatus(int userId) {
        if (goalStatusRepository.findByUserId(userId) != null) {
            throw new DataConflictException(GoalErrorCode.REGISTER_GOAL_STATUS_DUPLICATED.getMessage());
        }
        Map<LocalDate, Integer> firstResult = new HashMap<>();
        firstResult.put(LocalDate.now(), 0);

        GoalStatus goalStatus = GoalStatus.builder()
                .userId(userId)
                .result(firstResult)
                .build();
        goalStatusRepository.save(goalStatus);
    }

    @Override
    public GoalStatusDto getGoalStatus(int userId) {
        if (goalStatusRepository.findByUserId(userId) == null) {
            throw new NotFoundException(GoalErrorCode.NOT_FOUND_GOAL_STATUS.getMessage());
        }
        GoalStatus goalStatus = goalStatusRepository.findByUserId(userId);
        Map<LocalDate, Integer> allResult = goalStatus.getResult();
        return GoalStatusDto.builder()
                .goalStatusMap(allResult)
                .build();
//        if (LocalDate.now().isBefore(date)) {
//            throw new BadRequestException(GoalErrorCode.GET_FUTURE_GOAL_STATUS.getMessage());
//        } else if (goalStatusRepository.findByUserId(userId).getResult().get(date) == null) {
//            throw new NotFoundException(GoalErrorCode.NOT_FOUND_GOAL_STATUS.getMessage());
//        }
//        GoalStatus goalStatus = goalStatusRepository.findByUserId(userId);
//        Map<LocalDate, Integer> allResult = goalStatus.getResult();
//        int allResultSize = allResult.size();
//
//        LocalDate todayDate = LocalDate.now();
//        int period = Period.between(date, todayDate).getDays();
//
//        Map<LocalDate, Integer> result = new HashMap<>();
//        for (int i = period; i < period + 31; i++) {
//            if (i >= allResultSize) {
//                break;
//            }
//            result.put(date.minusDays(i), allResult.get(date.minusDays(i)));
//        }
//        return GoalStatusDto.builder()
//                .goalStatusMap(result)
//                .build();
    }

    @Override
    @Transactional
    public void updateGoalStatus(UpdateGoalStatusDto updateGoalStatusDto, Integer parentId) {
        GoalStatus goalStatus = goalStatusRepository.findByUserId(updateGoalStatusDto.getUserId());
        if (!userValidationUtils.isParentUserWithPermission(parentId, updateGoalStatusDto.getUserId())) {
            throw new DataAccessException(GoalErrorCode.UPDATE_GOAL_STATUS_ACCESS_DENIED.getMessage());
        } else if (!goalStatus.getResult().containsKey(updateGoalStatusDto.getDate())) {
            throw new NotFoundException(GoalErrorCode.UPDATE_GOAL_STATUS_NOT_FOUND.getMessage());
        }
        goalStatus.updateGoalStatus(updateGoalStatusDto.getDate(), updateGoalStatusDto.getStatus());
        goalStatusRepository.save(goalStatus);
    }
}
