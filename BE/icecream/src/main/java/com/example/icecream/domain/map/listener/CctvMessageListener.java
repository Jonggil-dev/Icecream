package com.example.icecream.domain.map.listener;

import com.example.icecream.domain.map.service.CctvMessageListenService;
import com.example.icecream.domain.map.dto.CctvMessageDto;
import com.example.icecream.domain.map.service.RedisListenService;
import com.example.icecream.domain.notification.dto.FcmRequestDto2;
import com.example.icecream.domain.notification.service.NotificationService;

import lombok.RequiredArgsConstructor;

import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@RequiredArgsConstructor
@Component
public class CctvMessageListener {

    private final CctvMessageListenService cctvMessageListenService;
    private final RedisListenService redisListenService;
    private final NotificationService notificationService;

    @RabbitListener(queues = "hello")
    public void receiveMessage(CctvMessageDto cctvMessageDto) {
        log.info("CCTV Name: {}, Speed: {}", cctvMessageDto.getCctvName(), cctvMessageDto.getSpeed());
        String CrosswalkName = cctvMessageListenService.findCrosswalk(cctvMessageDto);
        List<Integer> UserArray = redisListenService.getRedisValue(CrosswalkName);
        String message = "overspeed-1";
        if (cctvMessageDto.getSpeed() >= 45) {
            message = "overspeed-3";
        } else if (cctvMessageDto.getSpeed() >= 35) {
            message = "overspeed-2";
        }
        FcmRequestDto2 fcmRequestDto2 = new FcmRequestDto2(UserArray, "\\uD83D\\uDEA8 위험 알림 \\uD83D\\uDEA8", "근처에 과속 차량이 있어요. 주의하세요!", message);
        notificationService.sendMessageToUsers(fcmRequestDto2);
    }
}
