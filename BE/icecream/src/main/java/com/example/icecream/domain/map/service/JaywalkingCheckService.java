package com.example.icecream.domain.map.service;

import com.example.icecream.domain.goal.document.GoalStatus;
import com.example.icecream.domain.goal.entity.Goal;
import com.example.icecream.domain.goal.repository.mongodb.GoalStatusRepository;
import com.example.icecream.domain.goal.repository.postgres.GoalRepository;
import com.example.icecream.domain.map.entity.Road;
import com.example.icecream.domain.map.repository.RoadRepository;
import com.example.icecream.domain.notification.dto.FcmRequestDto2;
import com.example.icecream.domain.notification.service.NotificationService;
import com.example.icecream.domain.user.entity.User;
import com.example.icecream.domain.user.repository.ParentChildMappingRepository;
import com.example.icecream.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class JaywalkingCheckService {

    private final RoadRepository roadRepository;
    private final GeometryFactory geometryFactory;
    private final RedisTemplate<String, Integer> redisTemplate;
    private final GoalStatusRepository goalStatusRepository;
    private final GoalRepository goalRepository;
    private final ParentChildMappingRepository parentChildMappingRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public void checkJaywalking(int userId, double latitude, double longitude) {
        ValueOperations<String, Integer> ops = redisTemplate.opsForValue();
        Integer dailyGoal = ops.get("user_goal:" + userId);
        Point point = geometryFactory.createPoint(new Coordinate(longitude, latitude));
        for (Road road : roadRepository.findAll()) {
            if (road.getRoadArea().contains(point)) {
                if (dailyGoal == null || dailyGoal == 0) {
                    GoalStatus goalStatus = goalStatusRepository.findByUserId(userId);
                    goalStatus.getResult().put(LocalDate.now(), -1);
                    goalStatusRepository.save(goalStatus);

                    int parentId = parentChildMappingRepository.findByChildId(userId).getParent().getId();
                    User user = userRepository.findById(userId).orElseThrow();
                    List<Integer> userArray = Arrays.asList(userId, parentId);
                    FcmRequestDto2 fcmRequestDto2 = new FcmRequestDto2(userArray, "목표 달성 현황 초기화", user.getUsername() + "님이 무단횡단하였습니다.", "goal");
                    notificationService.sendMessageToUsers(fcmRequestDto2);

                    ops.set("user_goal:" + userId, 1);

                    Goal goal = goalRepository.findByUserIdAndIsActive(userId, true);
                    if (goal != null) {
                        goal.updateRecord(0);
                        goalRepository.save(goal);
                    }
                }
            }
        }
    }
}
