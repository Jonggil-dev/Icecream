package com.example.icecream.domain.goal.repository.mongodb;

import com.example.icecream.domain.goal.document.GoalStatus;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GoalStatusRepository extends MongoRepository<GoalStatus, String>{
    GoalStatus findByUserId(int userId);
}
