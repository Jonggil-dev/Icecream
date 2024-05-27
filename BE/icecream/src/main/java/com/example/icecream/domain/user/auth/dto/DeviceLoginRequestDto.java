package com.example.icecream.domain.user.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Getter
public class DeviceLoginRequestDto {

    @NotBlank
    @Size(max=20)
    private String deviceId;

    private String refreshToken;

    @NotBlank
    @Pattern(regexp = "^[a-zA-Z0-9\\-_:]{100,}$", message = "올바른 FCM 토큰 형식이 아닙니다.")
    private String fcmToken;
}
