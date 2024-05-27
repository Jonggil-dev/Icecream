package com.example.icecream.domain.user.auth.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class JwtTokenDto {
    private String accessToken;
    private String refreshToken;
}