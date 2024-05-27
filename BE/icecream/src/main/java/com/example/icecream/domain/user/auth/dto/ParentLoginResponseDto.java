package com.example.icecream.domain.user.auth.dto;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class ParentLoginResponseDto implements LoginResponseDto {

    private int userId;
    private String username;
    private String loginId;
    private String phoneNumber;
    private String profileImage;
    private List<ChildrenResponseDto> children;
    private String accessToken;
    private String refreshToken;
}
