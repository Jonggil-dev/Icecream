package com.example.icecream.domain.user.auth.handler;

import com.example.icecream.common.dto.ApiResponseDto;
import com.example.icecream.domain.user.auth.error.AuthErrorCode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
@RequiredArgsConstructor
public class CustomAccessDeniedHandler implements AccessDeniedHandler {

    private final ObjectMapper objectMapper;

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.setContentType("application/json; charset=UTF-8");
        ApiResponseDto<String> apiResponse = new ApiResponseDto<>(HttpServletResponse.SC_FORBIDDEN, AuthErrorCode.ACCESS_DENIED.getMessage(), null);
        response.getWriter().write(objectMapper.writeValueAsString(apiResponse));
    }
}
