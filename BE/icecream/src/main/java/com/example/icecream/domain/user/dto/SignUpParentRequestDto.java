package com.example.icecream.domain.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Getter
public class SignUpParentRequestDto {

    @NotBlank
    @Pattern(regexp = "^[가-힣a-zA-Z]+$", message = "사용자 이름은 한글 또는 영어로만 구성되어야 합니다.")
    private String username;

    @NotBlank
    @Pattern(regexp = "^010-(?:\\d{3}|\\d{4})-\\d{4}$", message = "올바른 휴대폰 번호 형식이 아닙니다.")
    private String phoneNumber;

    @NotBlank
    @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d)[a-zA-Z0-9]{6,20}$", message = "로그인 ID는 영문과 숫자를 포함한 6~20자리 이어야 합니다.")
    private String loginId;

    @NotBlank
    @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d)[a-zA-Z0-9!@#$%^&*]{8,20}$", message = "비밀번호는 영문과 숫자를 포함한 8~20자리 이어야 합니다.")
    private String password;

    @NotBlank
    private String passwordCheck;

    @NotBlank
    @Size(max=20)
    private String deviceId;
}

