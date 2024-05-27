package com.example.icecream.domain.map.listener;

import com.example.icecream.domain.map.dto.GPSMessageDto;
import com.example.icecream.domain.map.service.CrosswalkService;

import com.example.icecream.domain.map.service.DestinationArrivalService;
import com.example.icecream.domain.map.service.JaywalkingCheckService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.amqp.rabbit.annotation.RabbitListener;

import lombok.RequiredArgsConstructor;


@RequiredArgsConstructor
@Component
@Slf4j
public class GPSMessageListener {

    private final CrosswalkService crosswalkService;
    private final DestinationArrivalService destinationArrivalService;
    private final JaywalkingCheckService jaywalkingCheckService;

    @RabbitListener(queues = "crosswalk")
    public void receiveMessage(GPSMessageDto gpsMessageDto) {
        try {
            log.info("userId: {}, destinationId: {}, latitude: {}, longitude: {}", gpsMessageDto.getUserId(), gpsMessageDto.getDestinationId(), gpsMessageDto.getLatitude(), gpsMessageDto.getLongitude());
            crosswalkService.checkCrosswalkArea(gpsMessageDto.getUserId(), gpsMessageDto.getLatitude(), gpsMessageDto.getLongitude());
            destinationArrivalService.checkAndNotifyArrival(gpsMessageDto.getUserId(), gpsMessageDto.getDestinationId(), gpsMessageDto.getLatitude(), gpsMessageDto.getLongitude());
            jaywalkingCheckService.checkJaywalking(gpsMessageDto.getUserId(), gpsMessageDto.getLatitude(), gpsMessageDto.getLongitude());
        } catch (Exception e) {
//            log.error("Error processing message: {}", e.getMessage());
        }
    }
}