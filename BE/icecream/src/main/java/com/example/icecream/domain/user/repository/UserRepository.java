package com.example.icecream.domain.user.repository;

import com.example.icecream.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Integer>{
    Optional<User> findByIdAndIsDeletedFalse(int id);
    Optional<User> findByLoginIdAndIsDeletedFalse(String loginId);
    Optional<User> findByDeviceIdAndIsDeletedFalse(String deviceId);
    boolean existsByIdAndIsDeletedFalse(int id);
    boolean existsByLoginIdAndIsDeletedFalse(String loginId);

    List<User> findAllByIsParentAndIsDeletedFalse(boolean isParent);
}
