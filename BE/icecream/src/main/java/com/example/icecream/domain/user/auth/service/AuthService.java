package com.example.icecream.domain.user.auth.service;

import com.example.icecream.domain.user.auth.error.AuthErrorCode;
import com.example.icecream.domain.user.auth.util.JwtUtil;
import com.example.icecream.common.exception.NotFoundException;
import com.example.icecream.domain.notification.dto.LoginRequestDto;
import com.example.icecream.domain.notification.service.NotificationService;
import com.example.icecream.domain.user.entity.ParentChildMapping;
import com.example.icecream.domain.user.entity.User;
import com.example.icecream.domain.user.repository.ParentChildMappingRepository;
import com.example.icecream.domain.user.repository.UserRepository;
import com.example.icecream.domain.user.auth.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final ParentChildMappingRepository parentChildMappingRepository;
    private final JwtUtil jwtUtil;
    private final NotificationService notificationService;

    public LoginResponseDto deviceLogin(DeviceLoginRequestDto deviceLoginRequestDto) {

        User user = userRepository.findByDeviceIdAndIsDeletedFalse(deviceLoginRequestDto.getDeviceId())
                .orElseThrow(() -> new NotFoundException(AuthErrorCode.USER_NOT_FOUND.getMessage()));

        if (user.getIsParent()) {
            if (jwtUtil.validateRefreshToken(deviceLoginRequestDto.getRefreshToken(), String.valueOf(user.getId()))) {
                List<User> children = parentChildMappingRepository.findChildrenByParentId(user.getId());

                List<ChildrenResponseDto> childrenResponseDto = children.stream()
                        .map(child -> ChildrenResponseDto.builder()
                                .userId(child.getId())
                                .profileImage(child.getProfileImage())
                                .username(child.getUsername())
                                .phoneNumber(child.getPhoneNumber())
                                .build())
                        .toList();


                JwtTokenDto jwtTokenDto = jwtUtil.generateTokenByController(String.valueOf(user.getId()), "ROLE_PARENT");

                LoginRequestDto loginRequestDto = new LoginRequestDto(user.getId(), deviceLoginRequestDto.getFcmToken());
                notificationService.saveOrUpdateFcmToken(loginRequestDto);

                return ParentLoginResponseDto.builder()
                        .userId(user.getId())
                        .username(user.getUsername())
                        .loginId(user.getLoginId())
                        .phoneNumber(user.getPhoneNumber())
                        .profileImage(user.getProfileImage())
                        .children(childrenResponseDto)
                        .accessToken(jwtTokenDto.getAccessToken())
                        .refreshToken(jwtTokenDto.getRefreshToken())
                        .build();
            }
        }

        JwtTokenDto jwtTokenDto = jwtUtil.generateTokenByController(String.valueOf(user.getId()), "ROLE_CHILD");
        LoginRequestDto loginRequestDto = new LoginRequestDto(user.getId(), deviceLoginRequestDto.getFcmToken());
        notificationService.saveOrUpdateFcmToken(loginRequestDto);

        String parentPhoneNumber = parentChildMappingRepository.findByChildId(user.getId()).getParent().getPhoneNumber();

        return ChildLoginResponseDto.builder()
                .parentPhoneNumber(parentPhoneNumber)
                .userId(user.getId())
                .username(user.getUsername())
                .phoneNumber(user.getPhoneNumber())
                .profileImage(user.getProfileImage())
                .accessToken(jwtTokenDto.getAccessToken())
                .refreshToken(jwtTokenDto.getRefreshToken())
                .build();
    }
}