package com.example.icecream.domain.user.util;

import com.example.icecream.common.exception.DataAccessException;
import com.example.icecream.common.exception.DataConflictException;
import com.example.icecream.common.exception.NotFoundException;
import com.example.icecream.domain.user.entity.User;
import com.example.icecream.domain.user.error.UserErrorCode;
import com.example.icecream.domain.user.repository.UserRepository;
import com.example.icecream.domain.user.repository.ParentChildMappingRepository;
import org.springframework.security.authentication.BadCredentialsException;

import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class UserValidationUtils {
    private final UserRepository userRepository;
    private final ParentChildMappingRepository parentChildMappingRepository;

    public boolean isUserExist(Integer userId) {
        return userRepository.existsByIdAndIsDeletedFalse(userId);
    }

    public boolean isParentUserWithPermission(Integer parentId, Integer childId) {
        return parentChildMappingRepository.existsByParentIdAndChildId(parentId, childId);
    }

    public User isValidUser(int userId) {
        Optional<User> user = userRepository.findByIdAndIsDeletedFalse(userId);
        if (user.isEmpty()) {
            throw new NotFoundException(UserErrorCode.USER_NOT_FOUND.getMessage());
        }
        return user.get();
    }

    public void isValidLoginId(String loginId) {
        if (userRepository.existsByLoginIdAndIsDeletedFalse(loginId)) {
            throw new DataConflictException(UserErrorCode.DUPLICATE_LOGIN_ID.getMessage());
        }
    }

    public void isValidatePasswordCheck(String password, String passwordCheck) {
        if (!password.equals(passwordCheck)) {
            throw new BadCredentialsException(UserErrorCode.PASSWORD_MISMATCH.getMessage());
        }
    }

    public void isValidChild(int parentId,int childId){
        if (!parentChildMappingRepository.existsByParentIdAndChildId(parentId, childId)) {
            throw new DataAccessException(UserErrorCode.CHILD_NOT_ASSOCIATED.getMessage());
        }
    }
}
