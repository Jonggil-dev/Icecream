package com.example.icecream.domain.goal.repository.postgres;

import com.example.icecream.domain.goal.entity.Goal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GoalRepository extends JpaRepository<Goal, Integer> {

    List<Goal> findAllByUserId(int userId);

    Goal findByUserIdAndIsActive(int userId, boolean isActive);
}
