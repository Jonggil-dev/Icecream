package com.example.icecream.domain.notification.document;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class FcmTokenTest {

    @Test
    void fcmTokenBuilderTest() {
        FcmToken fcmToken = FcmToken.builder()
                .userId(1)
                .token("testFcmToken")
                .build();

        assertEquals(1, fcmToken.getUserId());
        assertEquals("testFcmToken", fcmToken.getToken());
    }
}
