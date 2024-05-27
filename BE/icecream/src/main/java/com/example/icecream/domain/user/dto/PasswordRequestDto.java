package com.example.icecream.domain.user.dto;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

@Getter
public class PasswordRequestDto {

    @NotBlank
    @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d)[a-zA-Z0-9!@#$%^&*]{8,20}$", message = "비밀번호는 영문과 숫자를 포함한 8~20자리 이어야 합니다.")
    private String password;
}
