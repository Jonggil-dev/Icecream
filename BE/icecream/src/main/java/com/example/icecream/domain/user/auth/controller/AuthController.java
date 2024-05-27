package com.example.icecream.domain.user.auth.controller;

import com.example.icecream.domain.user.auth.dto.JwtTokenDto;
import com.example.icecream.domain.user.auth.dto.LoginResponseDto;
import com.example.icecream.domain.user.auth.dto.RefreshTokenDto;
import com.example.icecream.domain.user.auth.service.AuthService;
import com.example.icecream.domain.user.auth.util.JwtUtil;
import com.example.icecream.common.dto.ApiResponseDto;
import com.example.icecream.domain.user.auth.dto.DeviceLoginRequestDto;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;
    private final JwtUtil jwtUtil;

    @PostMapping("/device/login")
    public ResponseEntity<ApiResponseDto<LoginResponseDto>> login(@RequestBody @Valid DeviceLoginRequestDto deviceLoginRequestDto)
    {
        return ApiResponseDto.success("로그인 되었습니다.", authService.deviceLogin(deviceLoginRequestDto));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponseDto<String>> logout(@RequestBody @Valid RefreshTokenDto refreshTokenDto, @AuthenticationPrincipal UserDetails userDetails) {
        jwtUtil.invalidateRefreshToken(refreshTokenDto.getRefreshToken(), userDetails.getUsername());
        return ApiResponseDto.success("로그아웃 되었습니다.");
    }

    @PostMapping("/reissue")
    public ResponseEntity<ApiResponseDto<JwtTokenDto>> reissue(@RequestBody @Valid RefreshTokenDto refreshTokenDto) {
        JwtTokenDto newToken = jwtUtil.reissueToken(refreshTokenDto.getRefreshToken());
        return ApiResponseDto.success("새로운 토큰이 발급되었습니다", newToken);
    }
}