package com.example.icecream.domain.notification.document;

import com.example.icecream.domain.notification.document.NotificationList;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class NotificationListTest {

    @Test
    void notificationListBuilderTest() {
        NotificationList notificationList = NotificationList.builder()
                .userId(1)
                .content("testNotification")
                .build();

        assertEquals(1, notificationList.getUserId());
        assertEquals("testNotification", notificationList.getContent());
    }
}
