package com.example.icecream.domain.user.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class LoginRequestDto {
    @NotBlank
    private String loginId;
    @NotBlank
    private String password;
    @NotBlank
    private String fcmToken;
}
