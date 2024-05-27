package com.example.icecream.domain.notification.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class FcmRequestDto {

    @NotNull
    private String token;
    @NotNull
    private String title;
    @NotNull
    private String body;
    @NotNull
    private String content;
}
