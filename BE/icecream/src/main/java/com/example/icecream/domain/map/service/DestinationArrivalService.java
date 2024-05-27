package com.example.icecream.domain.map.service;

import com.example.icecream.domain.map.entity.Destination;
import com.example.icecream.domain.map.repository.DestinationRepository;
import com.example.icecream.domain.notification.document.FcmToken;
import com.example.icecream.domain.notification.dto.FcmRequestDto;
import com.example.icecream.domain.notification.repository.FcmTokenRepository;
import com.example.icecream.domain.notification.service.NotificationService;
import com.example.icecream.domain.user.entity.User;
import com.example.icecream.domain.user.repository.ParentChildMappingRepository;
import com.example.icecream.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
@RequiredArgsConstructor
public class DestinationArrivalService {

    private final DestinationRepository destinationRepository;
    private final RedisTemplate<String, Integer> redisTemplate;
    private final FcmTokenRepository fcmTokenRepository;
    private final NotificationService notificationService;
    private final UserRepository userRepository;
    private final ParentChildMappingRepository parentChildMappingRepository;

    public void checkAndNotifyArrival(int userId, int destinationId, double latitude, double longitude) throws IOException {
        boolean isArrived = destinationRepository.isWithinRadius(destinationId, latitude, longitude);

        if (isArrived) {
            String key = "arrival:" + destinationId;
            ValueOperations<String, Integer> ops = redisTemplate.opsForValue();
            Integer alreadyArrived = ops.get(key);

            if (alreadyArrived == null || alreadyArrived == 0) {
                ops.set(key, 1);
                int parentId = parentChildMappingRepository.findByChildId(userId).getParent().getId();
                FcmToken fcmToken = fcmTokenRepository.findByUserId(parentId);
                User user = userRepository.findById(userId).orElseThrow();
                Destination destination = destinationRepository.findById(destinationId).orElseThrow();
                FcmRequestDto fcmRequestDto = new FcmRequestDto(fcmToken.getToken(), "도착 알림", user.getUsername() + "님이 " + destination.getName() + "에 도착했습니다.", "arrival");
                notificationService.sendMessageTo(fcmRequestDto);
            }
        }
    }
}
