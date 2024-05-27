package com.example.icecream.domain.notification.controller;

import com.example.icecream.domain.notification.controller.NotificationController;
import com.example.icecream.common.dto.ApiResponseDto;
import com.example.icecream.domain.notification.dto.NotificationResponseDto;
import com.example.icecream.domain.notification.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class NotificationControllerTest {

    @Mock
    private NotificationService notificationService;
    private UserDetails userDetails;

    @InjectMocks
    private NotificationController notificationController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("특정 사용자의 알림 목록 조회 API")
    void testGetNotificationList() {
        int userId = 1;
        String content1 = "testContent1";
        String content2 = "testContent2";
        LocalDateTime datetime1 = LocalDateTime.now();
        LocalDateTime datetime2 = LocalDateTime.now().plusHours(1);
        NotificationResponseDto notificationResponseDto1 = new NotificationResponseDto(content1, datetime1);
        NotificationResponseDto notificationResponseDto2 = new NotificationResponseDto(content2, datetime2);
        List<NotificationResponseDto> notificationResponseDtos = Arrays.asList(notificationResponseDto2, notificationResponseDto1);

        when(notificationService.getNotificationList(userId)).thenReturn(notificationResponseDtos);

        ResponseEntity<ApiResponseDto<List<NotificationResponseDto>>> result = notificationController.getNotificationList(userDetails);

        assertNotNull(result);
        assertEquals(HttpStatusCode.valueOf(200), result.getStatusCode());
        List<?> resultBody = result.getBody().getData();
        assertEquals(2, resultBody.size());
        assertInstanceOf(NotificationResponseDto.class, resultBody.get(0));
        assertInstanceOf(NotificationResponseDto.class, resultBody.get(1));
        assertEquals(content2, ((NotificationResponseDto) resultBody.get(0)).getContent());
        assertEquals(datetime2, ((NotificationResponseDto) resultBody.get(0)).getDatetime());
        assertEquals(content1, ((NotificationResponseDto) resultBody.get(1)).getContent());
        assertEquals(datetime1, ((NotificationResponseDto) resultBody.get(1)).getDatetime());

        verify(notificationService, times(1)).getNotificationList(userId);
    }
}
