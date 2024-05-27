package com.example.icecream.domain.notification.controller;

import com.example.icecream.common.dto.ApiResponseDto;
import com.example.icecream.domain.notification.dto.FcmRequestDto;
import com.example.icecream.domain.notification.dto.FcmRequestDto2;
import com.example.icecream.domain.notification.dto.NotificationResponseDto;
import com.example.icecream.domain.notification.service.NotificationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/notification")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<ApiResponseDto<List<NotificationResponseDto>>> getNotificationList(@AuthenticationPrincipal UserDetails userDetails) {
        List<NotificationResponseDto> notificationList = notificationService.getNotificationList(Integer.parseInt(userDetails.getUsername()));
        return ApiResponseDto.success("알림 목록 조회에 성공하였습니다.", notificationList);
    }

    @PostMapping("/fcmTest")
    public ResponseEntity<ApiResponseDto<String>> fcmTest(@RequestBody FcmRequestDto fcmRequestDto) {
        try {
            notificationService.sendMessageTo(fcmRequestDto);
        } catch (Exception e) {
            return ApiResponseDto.error(e.getMessage());
        }
        return ApiResponseDto.success("메시지 전송 성공");
    }

    @PostMapping("/fcmTest2")
    public ResponseEntity<ApiResponseDto<String>> fcmTest2(@RequestBody @Valid FcmRequestDto2 fcmRequestDto2) {
        try {
            notificationService.sendMessageToUsers(fcmRequestDto2);
        } catch (Exception e) {
            return ApiResponseDto.error(e.getMessage());
        }
        return ApiResponseDto.success("메시지 전송 성공");
    }
}
