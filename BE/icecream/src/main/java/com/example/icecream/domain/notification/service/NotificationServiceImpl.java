package com.example.icecream.domain.notification.service;

import com.example.icecream.domain.notification.document.NotificationList;
import com.example.icecream.domain.notification.dto.*;
import com.example.icecream.domain.notification.document.FcmToken;
import com.example.icecream.domain.notification.repository.FcmTokenRepository;
import com.example.icecream.domain.notification.repository.NotificationListRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.auth.oauth2.GoogleCredentials;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

@Slf4j
@Transactional(readOnly = true)
@Service
public class NotificationServiceImpl implements NotificationService {

    private final FcmTokenRepository fcmTokenRepository;
    private final NotificationListRepository notificationListRepository;
    private final String FCM_API_URL;
    private final ObjectMapper objectMapper;

    public NotificationServiceImpl(FcmTokenRepository fcmTokenRepository,
                                   NotificationListRepository notificationListRepository,
                                   @Value("${FCM_API_URL}") String FCM_API_URL,
                                   ObjectMapper objectMapper) {
        this.fcmTokenRepository = fcmTokenRepository;
        this.notificationListRepository = notificationListRepository;
        this.FCM_API_URL = FCM_API_URL;
        this.objectMapper = objectMapper;
    }

    @Override
    @Transactional
    public FcmToken saveOrUpdateFcmToken(LoginRequestDto loginRequestDto) {
        FcmToken fcmTokenEntity = fcmTokenRepository.findByUserId(loginRequestDto.getUserId());
        if (fcmTokenEntity == null) {
            fcmTokenEntity = FcmToken.builder()
                    .userId(loginRequestDto.getUserId())
                    .token(loginRequestDto.getToken())
                    .build();
        } else {
            fcmTokenEntity.updateToken(loginRequestDto.getToken());
        }
        return fcmTokenRepository.save(fcmTokenEntity);
    }

    @Override
    @Transactional
    public NotificationList saveNotificationList(Integer UserId, String content) {
        NotificationList notificationList = NotificationList.builder()
                .userId(UserId)
                .content(content)
                .build();
        return notificationListRepository.save(notificationList);
    }

    @Override
    public List<NotificationResponseDto> getNotificationList(Integer UserId) {
        List<NotificationList> notificationLists = notificationListRepository.findByUserIdOrderByCreatedAtDesc(UserId);
        return notificationLists.stream()
                .map(notification -> new NotificationResponseDto(notification.getContent(), notification.getCreatedAt()))
                .collect(Collectors.toList());
    }

    @Async
    @Override
    @Transactional
    public void sendMessageToUsers(FcmRequestDto2 fcmRequestDto2) {
        log.info("알림 대상 유저 ID: {}", fcmRequestDto2.getUserIds());
        AtomicInteger success = new AtomicInteger(0);
        AtomicInteger failed = new AtomicInteger(0);

        List<CompletableFuture<Void>> futures = fcmRequestDto2.getUserIds().stream()
                .map(userId -> CompletableFuture.runAsync(() -> {
                    FcmToken fcmToken = fcmTokenRepository.findByUserId(userId);
                    if (fcmToken != null) {
                        FcmRequestDto fcmRequestDto = new FcmRequestDto(fcmToken.getToken(), fcmRequestDto2.getTitle(), fcmRequestDto2.getBody(), fcmRequestDto2.getContent());
                        try {
                            sendMessageTo(fcmRequestDto);
                            success.incrementAndGet();
                        } catch (IOException e) {
                            throw new RuntimeException("Failed to send message to FCM", e);
                        }
                    } else {
                        throw new RuntimeException("Failed to find FCM token by userId: " + userId);
                    }
                }, Executors.newCachedThreadPool()).exceptionally((ex) -> {
                    failed.incrementAndGet();
                    log.error("에러 발생: {}", ex.getMessage());
                    return null;
                }))
                .toList();

        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
                .thenRun(() -> log.info("FCM 전송 완료: 성공 {}, 실패 {}", success.get(), failed.get()));
    }

    @Override
    @Transactional
    public void sendMessageTo(FcmRequestDto fcmRequestDto) throws IOException {
        String message = createMessage(fcmRequestDto);

        OkHttpClient client = new OkHttpClient();
        RequestBody requestBody = RequestBody.create(message,
                MediaType.get("application/json; charset=utf-8"));
        Request request = new Request.Builder()
                .url(FCM_API_URL)
                .post(requestBody)
                .addHeader(HttpHeaders.AUTHORIZATION, "Bearer " + getAccessToken())
                .addHeader(HttpHeaders.CONTENT_TYPE, "application/json; UTF-8")
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (response.body() != null) {
                if (fcmRequestDto.getContent().equals("arrival") || fcmRequestDto.getContent().equals("goal")) {
                    saveNotificationList(fcmTokenRepository.findByToken(fcmRequestDto.getToken()).getUserId(), fcmRequestDto.getBody());
                }
            } else {
                throw new IOException("Failed to send message to FCM");
            }
        } catch (IOException e) {
            throw new IOException("Failed to send message to FCM", e);
        }
    }

    @Override
    public String getAccessToken() throws IOException {
        String firebaseConfigPath = "fcm-admin-sdk.json";

        GoogleCredentials googleCredentials = GoogleCredentials
                .fromStream(new ClassPathResource(firebaseConfigPath).getInputStream())
                .createScoped(List.of("https://www.googleapis.com/auth/cloud-platform"));

        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
    }

    @Override
    @Transactional
    public String createMessage(FcmRequestDto fcmRequestDto) throws JsonProcessingException {
        FcmMessageDto fcmMessageDto = FcmMessageDto.builder()
                .validateOnly(false)
                .message(FcmMessageDto.Message.builder()
                        .token(fcmRequestDto.getToken())
                        .data(FcmMessageDto.Data.builder()
                                .title(fcmRequestDto.getTitle())
                                .body(fcmRequestDto.getBody())
                                .content(fcmRequestDto.getContent())
                                .build())
                        .build())
                .build();

        return objectMapper.writeValueAsString(fcmMessageDto);
    }
}
