package com.example.icecream.domain.notification.service;

import com.example.icecream.domain.notification.document.FcmToken;
import com.example.icecream.domain.notification.document.NotificationList;
import com.example.icecream.domain.notification.dto.FcmRequestDto;
import com.example.icecream.domain.notification.dto.FcmRequestDto2;
import com.example.icecream.domain.notification.dto.LoginRequestDto;
import com.example.icecream.domain.notification.dto.NotificationResponseDto;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.firebase.auth.FirebaseAuthException;

import java.io.IOException;
import java.util.List;

public interface NotificationService {

    FcmToken saveOrUpdateFcmToken(LoginRequestDto loginRequestDto);
    NotificationList saveNotificationList(Integer UserId, String content);
    List<NotificationResponseDto> getNotificationList(Integer UserId);
    void sendMessageTo(FcmRequestDto fcmRequestDto) throws IOException;
    String getAccessToken() throws IOException;
    String createMessage(FcmRequestDto fcmRequestDto) throws JsonProcessingException;
    void sendMessageToUsers(FcmRequestDto2 fcmRequestDto2);
}
