package com.example.icecream.domain.user.auth.handler;

import com.example.icecream.domain.user.auth.error.AuthErrorCode;
import com.example.icecream.common.dto.ApiResponseDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class CustomAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper;

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json; charset=UTF-8");
        ApiResponseDto<String> apiResponse = new ApiResponseDto<>(HttpServletResponse.SC_UNAUTHORIZED, AuthErrorCode.INVALID_AUTHENTICATION.getMessage(), null);
        response.getWriter().write(objectMapper.writeValueAsString(apiResponse));
    }
}