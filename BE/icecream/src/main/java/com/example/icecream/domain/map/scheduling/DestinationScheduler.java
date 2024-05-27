package com.example.icecream.domain.map.scheduling;

import com.example.icecream.domain.map.repository.DestinationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDate;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DestinationScheduler {

    private final DestinationRepository destinationRepository;
    private final RedisTemplate<String, Integer> redisTemplate;

    @Scheduled(cron = "0 0 0 * * ?")
    public void scheduleDestinations() {
        int dayIndex = LocalDate.now().getDayOfWeek().getValue();
        List<Integer> destinationIds = destinationRepository.findActiveDestinationsByDayIndex(dayIndex);

        ValueOperations<String, Integer> ops = redisTemplate.opsForValue();
        destinationIds.forEach(destinationId -> {
            String key = "arrival:" + destinationId;
            ops.set(key, 0, Duration.ofSeconds(86400));
        });
    }
}
