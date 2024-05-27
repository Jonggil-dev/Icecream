package com.example.icecream.domain.user.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class RefreshTokenDto {

    @NotBlank
    private String refreshToken;
}
