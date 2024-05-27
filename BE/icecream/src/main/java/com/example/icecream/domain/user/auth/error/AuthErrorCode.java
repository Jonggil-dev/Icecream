package com.example.icecream.domain.user.auth.error;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum AuthErrorCode {

    INVALID_TOKEN("유효하지 않은 토큰입니다."),
    INVALID_AUTHENTICATION("유효하지 않은 Access 토큰이거나 로그인 정보가 일치하지 않습니다."),
    INVALID_HTTP_METHOD("로그인은 POST 요청만 가능합니다"),
    INPUT_SERIALIZE_FAIL("입력 정보를 역직렬화 하는데 실패했습니다."),
    NO_TOKEN_IN_REDIS("Redis에 해당 Refresh Token이 존재하지 않습니다"),
    USER_NOT_FOUND("등록된 유저 정보를 찾을 수 없습니다"),
    ACCESS_DENIED("해당 요청을 사용할 권한이 없습니다.");

    private final String message;
}
