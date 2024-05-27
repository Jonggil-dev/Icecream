package com.example.icecream.domain.user.auth.handler;

import com.example.icecream.domain.user.auth.dto.ChildrenResponseDto;
import com.example.icecream.domain.user.auth.dto.JwtTokenDto;
import com.example.icecream.domain.user.auth.dto.ParentLoginResponseDto;
import com.example.icecream.domain.user.auth.util.JwtUtil;
import com.example.icecream.common.dto.ApiResponseDto;
import com.example.icecream.domain.notification.dto.LoginRequestDto;
import com.example.icecream.domain.notification.service.NotificationService;
import com.example.icecream.domain.user.entity.User;
import com.example.icecream.domain.user.repository.ParentChildMappingRepository;
import com.example.icecream.domain.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.List;
import java.util.regex.Pattern;

@Component
@RequiredArgsConstructor
public class CustomAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

    private final ObjectMapper objectMapper;
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;
    private final ParentChildMappingRepository parentChildMappingRepository;
    private final NotificationService notificationService;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException {
        User user = userRepository.findByLoginIdAndIsDeletedFalse(authentication.getName()).orElseThrow(() -> new IllegalArgumentException("존재하지 않는 유저 입니다."));
        List<User> children = parentChildMappingRepository.findChildrenByParentId(user.getId());

        List<ChildrenResponseDto> childrenResponseDto = children.stream()
                .map(child -> ChildrenResponseDto.builder()
                        .userId(child.getId())
                        .profileImage(child.getProfileImage())
                        .username(child.getUsername())
                        .phoneNumber(child.getPhoneNumber())
                        .build())
                .toList();

        JwtTokenDto jwtToken = jwtUtil.generateTokenByFilterChain(authentication, user.getId());

        String fcmToken = (String) request.getAttribute("fcmToken");

        if (fcmToken == null || !Pattern.compile("^[a-zA-Z0-9\\-_:]{100,}$").matcher(fcmToken).matches()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\": \"올바른 FCM 토큰 형식이 아닙니다.\"}");
            response.getWriter().flush();
            return;
        }

        LoginRequestDto loginRequestDto = new LoginRequestDto(user.getId(), fcmToken);
        notificationService.saveOrUpdateFcmToken(loginRequestDto);

        ParentLoginResponseDto parentLoginResponseDto = ParentLoginResponseDto.builder()
                .userId(user.getId())
                .username(user.getUsername())
                .loginId(user.getLoginId())
                .phoneNumber(user.getPhoneNumber())
                .profileImage(user.getProfileImage())
                .children(childrenResponseDto)
                .accessToken(jwtToken.getAccessToken())
                .refreshToken(jwtToken.getRefreshToken())
                .build();

        ApiResponseDto<ParentLoginResponseDto> apiResponse = new ApiResponseDto<>(200, "로그인 되었습니다.", parentLoginResponseDto);

        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(objectMapper.writeValueAsString(apiResponse));
        response.getWriter().flush();
    }
}
