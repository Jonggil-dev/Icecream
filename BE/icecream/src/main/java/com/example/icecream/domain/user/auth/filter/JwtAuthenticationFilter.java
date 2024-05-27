package com.example.icecream.domain.user.auth.filter;

import com.example.icecream.common.dto.ApiResponseDto;
import com.example.icecream.domain.user.auth.error.AuthErrorCode;
import com.example.icecream.domain.user.auth.util.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.jetbrains.annotations.NotNull;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtutil;
    private final ObjectMapper objectMapper;

    @Override
    protected void doFilterInternal(HttpServletRequest request, @NotNull HttpServletResponse response, @NotNull FilterChain filterChain) throws ServletException, IOException {

        //PermitAll() url에 대해서는 다음 필터로 요청을 바로 넘김
        String requestURI = request.getRequestURI();
        List<String> skipUrls = List.of("/api/users/check", "/api/auth/login", "/api/auth/device/login", "/api/auth/reissue", "/api/error");
        boolean skip = skipUrls.stream().anyMatch(requestURI::equals);
        if ("/api/users".equals(requestURI) && "POST".equalsIgnoreCase(request.getMethod())) {
            skip = true;
        }
        if (skip) {
            filterChain.doFilter(request, response);
            return;
        }

        //access_token 검증
        String token = resolveToken(request);
        try {
            if (token != null && jwtutil.validateAccessToken(token)) {
                Authentication authentication = jwtutil.getAuthentication(token);
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json; charset=UTF-8");
            ApiResponseDto<String> apiResponse = new ApiResponseDto<>(HttpServletResponse.SC_UNAUTHORIZED, AuthErrorCode.INVALID_TOKEN.getMessage(), null);
            response.getWriter().write(objectMapper.writeValueAsString(apiResponse));
            return;
        }


        filterChain.doFilter(request, response);
    }

    private String resolveToken(HttpServletRequest request) {
            String bearerToken = request.getHeader("Authorization");

            if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer")) {
                return bearerToken.substring(7);
            }

            return null;
    }
}