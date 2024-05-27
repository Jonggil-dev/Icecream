package com.example.icecream.domain.goal.component;

import com.example.icecream.domain.goal.document.GoalStatus;
import com.example.icecream.domain.goal.entity.Goal;
import com.example.icecream.domain.goal.repository.mongodb.GoalStatusRepository;
import com.example.icecream.domain.goal.repository.postgres.GoalRepository;
import com.example.icecream.domain.notification.dto.FcmRequestDto2;
import com.example.icecream.domain.notification.service.NotificationService;
import com.example.icecream.domain.user.entity.User;
import com.example.icecream.domain.user.repository.ParentChildMappingRepository;
import com.example.icecream.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class ScheduleGoalStatusComponent {

    private final UserRepository userRepository;
    private final GoalStatusRepository goalStatusRepository;
    private final GoalRepository goalRepository;
    private final ParentChildMappingRepository parentChildMappingRepository;
    private final RedisTemplate<String, Integer> redisTemplate;
    private final NotificationService notificationService;

    @Scheduled(cron = "05 0 0 * * *")  // 초, 분, 시, 일, 월, 요일
    public void scheduleGoalStatusAndRedis() {
        List<User> users = userRepository.findAllByIsParentAndIsDeletedFalse(false);
        ValueOperations<String, Integer> ops = redisTemplate.opsForValue();

        users.forEach(user -> {
            int userId = user.getId();
            GoalStatus goalStatus = goalStatusRepository.findByUserId(userId);
            Map<LocalDate, Integer> result = goalStatus.getResult();
            if (result.get(LocalDate.now().minusDays(1)) == 0) {
                result.put(LocalDate.now().minusDays(1), 1);

                Goal goal = goalRepository.findByUserIdAndIsActive(userId, true);
                if (goal != null){
                    int record = goal.getRecord();
                    goal.updateRecord(record + 1);
                    goalRepository.save(goal);
                }
            }
            result.put(LocalDate.now(), 0);
            goalStatusRepository.save(goalStatus);

            String key = "user_goal:" + userId;
            ops.set(key, 0, Duration.ofSeconds(86400));
        });
    }

    @Scheduled(cron = "00 0 8 * * *")
    public void sendGoalAchievementNotification() {
        List<User> users = userRepository.findAllByIsParentAndIsDeletedFalse(false);

        users.forEach(user -> {
            int userId = user.getId();
            Goal goal = goalRepository.findByUserIdAndIsActive(userId, true);
            if (goal.getRecord() == goal.getPeriod()) {
                goal.deactivateGoal();
                int parentId = parentChildMappingRepository.findByChildId(userId).getParent().getId();
                List<Integer> userArray = Arrays.asList(userId, parentId);
                FcmRequestDto2 fcmRequestDto2 = new FcmRequestDto2(userArray, "목표 달성", user.getUsername() + "님, 목표를 달성하였습니다. 축하합니다!", "goal");
                notificationService.sendMessageToUsers(fcmRequestDto2);
                goalRepository.save(goal);
            }
        });
    }
}
