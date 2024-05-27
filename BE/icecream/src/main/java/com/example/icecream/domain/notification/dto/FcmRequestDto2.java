package com.example.icecream.domain.notification.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class FcmRequestDto2 {

    @NotNull
    private List<Integer> userIds;
    @NotNull
    private String title;
    @NotNull
    private String body;
    @NotNull
    private String content;
}
