package com.example.icecream.domain.user.repository;

import com.example.icecream.domain.user.entity.ParentChildMapping;
import com.example.icecream.domain.user.entity.User;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ParentChildMappingRepository extends JpaRepository<ParentChildMapping, Integer> {
    boolean existsByParentIdAndChildId(int parentId, int childId);
    void deleteByParentIdAndChildId(int parentId, int childId);
    void deleteByParentId(int parentId);

    @Query("SELECT p.child FROM ParentChildMapping p WHERE p.parent.id = :parentId")
    List<User> findChildrenByParentId(@Param("parentId") int parentId);

    @Query("SELECT p.child FROM ParentChildMapping p WHERE p.parent.loginId = :loginId")
    List<User> findChildrenByParentLoginId(@Param("loginId") String loginId);

    ParentChildMapping findByChildId(Integer childId);
}
