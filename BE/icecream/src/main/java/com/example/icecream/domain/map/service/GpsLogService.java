package com.example.icecream.domain.map.service;

import com.example.icecream.common.exception.NotFoundException;
import com.example.icecream.domain.map.dto.GpsResponseDto;
import com.example.icecream.domain.map.entity.GpsLog;
import com.example.icecream.domain.map.repository.elastic.GpsLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GpsLogService {

    private final GpsLogRepository gpsLogRepository;

    public GpsResponseDto findLatestGpsLogByUserId(Integer userId) {
        Pageable pageable = PageRequest.of(0, 1, Sort.by("@timestamp").descending());
        Page<GpsLog> page = gpsLogRepository.findByUserId(userId, pageable);
        GpsLog gpsLog =  page.hasContent() ? page.getContent().get(0) : null;
        if (gpsLog == null) {
            throw new NotFoundException("Gps Log가 존재하지 않습니다.");
        }
        return new GpsResponseDto(gpsLog.getUserId(), gpsLog.getLatitude(), gpsLog.getLongitude(), gpsLog.getDestinationId(), gpsLog.getTimestamp().toString());
    }
}
