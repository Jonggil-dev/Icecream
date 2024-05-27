package com.example.icecream.domain.map.controller;

import com.example.icecream.common.dto.ApiResponseDto;
import com.example.icecream.domain.map.dto.GpsResponseDto;
import com.example.icecream.domain.map.service.GpsLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/gps")
public class GpsController {

    private final GpsLogService gpsLogService;

    @GetMapping
    public ResponseEntity<ApiResponseDto<GpsResponseDto>> getGps(@RequestParam("user_id") Integer childId) {
        GpsResponseDto gps = gpsLogService.findLatestGpsLogByUserId(childId);
        return ApiResponseDto.success("최근 GPS 조회에 성공하였습니다.", gps);
    }
}
