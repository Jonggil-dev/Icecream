package com.example.icecream.domain.notification.service;

import com.example.icecream.domain.notification.document.FcmToken;
import com.example.icecream.domain.notification.document.NotificationList;
import com.example.icecream.domain.notification.dto.FcmRequestDto;
import com.example.icecream.domain.notification.dto.FcmRequestDto2;
import com.example.icecream.domain.notification.dto.LoginRequestDto;
import com.example.icecream.domain.notification.dto.NotificationResponseDto;
import com.example.icecream.domain.notification.repository.FcmTokenRepository;
import com.example.icecream.domain.notification.repository.NotificationListRepository;
import com.example.icecream.domain.notification.service.NotificationServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;

import okhttp3.mockwebserver.MockResponse;
import okhttp3.mockwebserver.MockWebServer;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.test.context.ActiveProfiles;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.CountDownLatch;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ActiveProfiles("local")
public class NotificationServiceTest {

    @Mock
    private FcmTokenRepository fcmTokenRepository;

    @Mock
    private NotificationListRepository notificationListRepository;

    private MockWebServer mockWebServer;

    @InjectMocks
    private NotificationServiceImpl notificationService;

    @BeforeEach
    void setUp() throws IOException {
        MockitoAnnotations.openMocks(this);
        ObjectMapper objectMapper = new ObjectMapper();
        mockWebServer = new MockWebServer();
        mockWebServer.start();
        notificationService = new NotificationServiceImpl(fcmTokenRepository, notificationListRepository, mockWebServer.url("/").toString(), objectMapper);
    }

    @AfterEach
    void tearDown() throws IOException {
        mockWebServer.shutdown();
    }

    @Test
    @DisplayName("새로운 유저일 경우 FcmToken 저장")
    void testSaveOrUpdateFcmToken_saveToken() {
        int userId = 1;
        String token = "testFcmToken";
        LoginRequestDto loginRequestDto = new LoginRequestDto(userId, token);

        when(fcmTokenRepository.findByUserId(userId)).thenReturn(null);
        when(fcmTokenRepository.save(any(FcmToken.class))).thenAnswer(invocation -> invocation.getArgument(0));

        FcmToken result = notificationService.saveOrUpdateFcmToken(loginRequestDto);

        assertNotNull(result);
        assertEquals(userId, result.getUserId());
        assertEquals(token, result.getToken());

        verify(fcmTokenRepository, times(1)).findByUserId(userId);
        verify(fcmTokenRepository, times(1)).save(any(FcmToken.class));
    }

    @Test
    @DisplayName("기존 유저일 경우 FcmToken 업데이트")
    void testSaveOrUpdateFcmToken_updateToken() {
        int userId = 1;
        String token = "testFcmToken";
        LoginRequestDto loginRequestDto = new LoginRequestDto(userId, token);
        FcmToken existingToken = FcmToken.builder()
                .userId(userId)
                .token("oldToken")
                .build();

        when(fcmTokenRepository.findByUserId(userId)).thenReturn(existingToken);
        when(fcmTokenRepository.save(any(FcmToken.class))).thenAnswer(invocation -> invocation.getArgument(0));

        FcmToken result = notificationService.saveOrUpdateFcmToken(loginRequestDto);

        assertNotNull(result);
        assertEquals(userId, result.getUserId());
        assertEquals(token, result.getToken());

        verify(fcmTokenRepository, times(1)).findByUserId(userId);
        verify(fcmTokenRepository, times(1)).save(any(FcmToken.class));
    }

    @Test
    @DisplayName("NotificationList 저장 테스트")
    void testSaveNotificationList() {
        int userId = 1;
        String content = "testContent";
        NotificationList notificationList = NotificationList.builder()
                .userId(userId)
                .content(content)
                .build();

        when(notificationListRepository.save(any(NotificationList.class))).thenReturn(notificationList);

        NotificationList result = notificationService.saveNotificationList(userId, content);

        assertNotNull(result);
        assertEquals(userId, result.getUserId());
        assertEquals(content, result.getContent());

        verify(notificationListRepository, times(1)).save(any(NotificationList.class));
    }

    @Test
    @DisplayName("특정 사용자의 NotificationList(최신 날짜 우선 정렬) 조회")
    void testGetNotificationList() {
        int userId = 1;
        String content1 = "testContent1";
        String content2 = "testContent2";
        NotificationList notificationList1 = NotificationList.builder()
                .userId(userId)
                .content(content1)
                .build();
        NotificationList notificationList2 = NotificationList.builder()
                .userId(userId)
                .content(content2)
                .build();
        List<NotificationList> notificationLists = Arrays.asList(notificationList2, notificationList1);

        when(notificationListRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(notificationLists);

        List<NotificationResponseDto> result = notificationService.getNotificationList(userId);

        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals(content2, result.get(0).getContent());
        assertEquals(content1, result.get(1).getContent());

        verify(notificationListRepository, times(1)).findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Test
    @DisplayName("특정 유저에게 알림 발송(개인)")
    void testSendMessageTo() throws IOException {
        String token = "testFcmToken";
        FcmRequestDto fcmRequestDto = new FcmRequestDto(token, "title", "body", "key1", "key2", "key3");

        FcmToken mockFcmToken = FcmToken.builder()
                .userId(1)
                .token(token)
                .build();

        when(fcmTokenRepository.findByToken(token)).thenReturn(mockFcmToken);

        mockWebServer.enqueue(new MockResponse().setBody("success"));

        notificationService.sendMessageTo(fcmRequestDto);

        verify(fcmTokenRepository, times(1)).findByToken(token);
    }

    @Test
    @DisplayName("특정 유저들에게 알림 발송(단체)")
    void testSendMessageToUsers() throws InterruptedException {
        List<Integer> userIds = Arrays.asList(1, 2, 3);
        FcmRequestDto2 fcmRequestDto2 = new FcmRequestDto2(userIds, "title", "body", "key1", "key2", "key3");

        CountDownLatch latch = new CountDownLatch(userIds.size());

        doAnswer(invocation -> {
            latch.countDown();
            return null;
        }).when(fcmTokenRepository).findByUserId(anyInt());

        notificationService.sendMessageToUsers(fcmRequestDto2);

        latch.await();

        for (Integer userId : userIds) {
            verify(fcmTokenRepository, times(1)).findByUserId(userId);
        }
    }
}