package com.example.icecream.domain.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Getter
public class DeviceIdRequestDto {

    @NotNull
    private Integer userId;

    @NotBlank
    @Size(max=20)
    private String deviceId;
}
