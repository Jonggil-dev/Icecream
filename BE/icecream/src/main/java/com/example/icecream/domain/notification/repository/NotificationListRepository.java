package com.example.icecream.domain.notification.repository;

import com.example.icecream.domain.notification.document.NotificationList;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationListRepository extends MongoRepository<NotificationList, String> {

    List<NotificationList> findByUserIdOrderByCreatedAtDesc(int userId);
}
