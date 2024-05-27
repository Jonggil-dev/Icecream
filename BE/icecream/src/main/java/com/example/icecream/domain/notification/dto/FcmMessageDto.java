package com.example.icecream.domain.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class FcmMessageDto {

    private boolean validateOnly;
    private Message message;

    @Getter
    @Builder
    @AllArgsConstructor
    public static class Message {
        private String token;
        private Data data;
    }

    @Getter
    @Builder
    @AllArgsConstructor
    public static class Data {
        private String title;
        private String body;
        private String content;
    }
}
