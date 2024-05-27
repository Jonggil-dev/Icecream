package com.example.icecream.domain.notification.repository;

import com.example.icecream.common.config.MongoConfig;
import com.example.icecream.domain.notification.document.NotificationList;
import com.example.icecream.domain.notification.repository.NotificationListRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.data.mongo.DataMongoTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;

import java.time.ZoneId;

import static org.junit.jupiter.api.Assertions.*;

@DataMongoTest
@ActiveProfiles("local")
@Import(MongoConfig.class)
public class NotificationListRepositoryTest {

    @Autowired
    private NotificationListRepository notificationListRepository;

    @AfterEach
    void tearDown() {
        notificationListRepository.deleteAll();
    }

    @Test
    void saveNotificationList() {
        NotificationList notificationList = NotificationList.builder()
                .userId(1)
                .content("testContent")
                .build();
        NotificationList saveNotificationList = notificationListRepository.save(notificationList);

        assertNotNull(saveNotificationList.getId());
        assertEquals(notificationList.getUserId(), saveNotificationList.getUserId());
        assertEquals(notificationList.getContent(), saveNotificationList.getContent());
        assertNotNull(saveNotificationList.getCreatedAt());
        assertNotNull(saveNotificationList.getUpdatedAt());
    }

    @Test
    void deleteNotificationList() {
        NotificationList notificationList = NotificationList.builder()
                .userId(2)
                .content("testContent")
                .build();
        NotificationList saveNotificationList = notificationListRepository.save(notificationList);

        notificationListRepository.delete(saveNotificationList);

        assertFalse(notificationListRepository.existsById(saveNotificationList.getId()));
    }

    @Test
    void findByUserIdOrderByCreatedAtDesc() {
        NotificationList notificationList1 = NotificationList.builder()
                .userId(3)
                .content("testContent1")
                .build();
        notificationListRepository.save(notificationList1);
        NotificationList notificationList2 = NotificationList.builder()
                .userId(3)
                .content("testContent2")
                .build();
        notificationListRepository.save(notificationList2);
        NotificationList notificationList3 = NotificationList.builder()
                .userId(3)
                .content("testContent3")
                .build();
        NotificationList saveNotificationList3 = notificationListRepository.save(notificationList3);

        NotificationList findNotificationList = notificationListRepository.findByUserIdOrderByCreatedAtDesc(3).get(0);

        assertEquals(saveNotificationList3.getId(), findNotificationList.getId());
        assertEquals(saveNotificationList3.getUserId(), findNotificationList.getUserId());
        assertEquals(saveNotificationList3.getContent(), findNotificationList.getContent());
        double expectedCreatedAt = saveNotificationList3.getCreatedAt().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
        double actualCreatedAt = findNotificationList.getCreatedAt().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
        assertEquals(expectedCreatedAt, actualCreatedAt, 0.001);
        double expectedUpdatedAt = saveNotificationList3.getUpdatedAt().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
        double actualUpdatedAt = findNotificationList.getUpdatedAt().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
        assertEquals(expectedUpdatedAt, actualUpdatedAt, 0.001);
    }

    @Test
    void findByUserIdOrderByCreatedAtDescNotFound() {
        assertTrue(notificationListRepository.findByUserIdOrderByCreatedAtDesc(4).isEmpty());
    }
}
