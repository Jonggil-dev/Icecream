package com.example.icecream.domain.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Getter
public class SignUpChildRequestDto {

    @NotBlank
    @Pattern(regexp = "^[가-힣a-zA-Z]+$", message = "사용자 이름은 한글 또는 영어로만 구성되어야 합니다.")
    private String username;

    @NotBlank
    @Pattern(regexp = "^01(?:0|1|[6-9])-(?:\\d{3}|\\d{4})-\\d{4}$", message = "올바른 휴대폰 번호 형식이 아닙니다.")
    private String phoneNumber;

    @NotBlank
    @Size(max=20)
    private String deviceId;

    @NotBlank
    @Pattern(regexp = "^[a-zA-Z0-9\\-_:]{100,}$", message = "올바른 FCM 토큰 형식이 아닙니다.")
    private String fcmToken;
}
