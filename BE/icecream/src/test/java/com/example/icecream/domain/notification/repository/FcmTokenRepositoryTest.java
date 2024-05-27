package com.example.icecream.domain.notification.repository;

import com.example.icecream.common.config.MongoConfig;
import com.example.icecream.domain.notification.document.FcmToken;
import com.example.icecream.domain.notification.repository.FcmTokenRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.data.mongo.DataMongoTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@DataMongoTest
@ActiveProfiles("local")
@Import(MongoConfig.class)
public class FcmTokenRepositoryTest {

    @Autowired
    private FcmTokenRepository fcmTokenRepository;

    @AfterEach
    void tearDown() {
        fcmTokenRepository.deleteAll();
    }

    @Test
    void testSaveFcmToken() {
        FcmToken fcmToken = FcmToken.builder()
                .userId(1)
                .token("testFcmToken")
                .build();
        FcmToken saveFcmToken = fcmTokenRepository.save(fcmToken);

        assertNotNull(saveFcmToken.getId());
        assertEquals(fcmToken.getUserId(), saveFcmToken.getUserId());
        assertEquals(fcmToken.getToken(), saveFcmToken.getToken());
        assertNotNull(saveFcmToken.getCreatedAt());
        assertNotNull(saveFcmToken.getUpdatedAt());
    }

    @Test
    void testDeleteFcmToken() {
        FcmToken fcmToken = FcmToken.builder()
                .userId(2)
                .token("testFcmToken")
                .build();
        FcmToken saveFcmToken = fcmTokenRepository.save(fcmToken);

        fcmTokenRepository.delete(saveFcmToken);

        assertFalse(fcmTokenRepository.existsById(saveFcmToken.getId()));
    }

    @Test
    void testFindByUserId() {
        FcmToken fcmToken = FcmToken.builder()
                .userId(3)
                .token("testFcmToken")
                .build();
        fcmTokenRepository.save(fcmToken);

        FcmToken findFcmToken = fcmTokenRepository.findByUserId(3);

        assertNotNull(findFcmToken);
        assertEquals(fcmToken.getUserId(), findFcmToken.getUserId());
        assertEquals(fcmToken.getToken(), findFcmToken.getToken());
        assertNotNull(findFcmToken.getCreatedAt());
        assertNotNull(findFcmToken.getUpdatedAt());
    }

    @Test
    void testFindByUserIdNotFound() {
        FcmToken findFcmToken = fcmTokenRepository.findByUserId(4);

        assertNull(findFcmToken);
    }

    @Test
    void testFindByToken() {
        FcmToken fcmToken = FcmToken.builder()
                .userId(5)
                .token("testFcmToken")
                .build();
        fcmTokenRepository.save(fcmToken);

        FcmToken findFcmToken = fcmTokenRepository.findByToken("testFcmToken");

        assertNotNull(findFcmToken);
        assertEquals(fcmToken.getUserId(), findFcmToken.getUserId());
        assertEquals(fcmToken.getToken(), findFcmToken.getToken());
        assertNotNull(findFcmToken.getCreatedAt());
        assertNotNull(findFcmToken.getUpdatedAt());
    }

    @Test
    void testFindByTokenNotFound() {
        FcmToken findFcmToken = fcmTokenRepository.findByToken("testFcmTokenEmpty");

        assertNull(findFcmToken);
    }
}
