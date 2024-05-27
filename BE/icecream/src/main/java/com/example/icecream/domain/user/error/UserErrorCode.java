package com.example.icecream.domain.user.error;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum UserErrorCode {

    USER_NOT_FOUND("등록된 유저 정보를 찾을 수 없습니다"),
    PASSWORD_MISMATCH("비밀번호와 비밀번호 확인이 일치하지 않습니다."),
    NOT_CHILD("이름을 변경하려는 대상이 부모 유저 입니다."),
    CHILD_NOT_ASSOCIATED("현재 부모에 등록된 자녀가 아닙니다."),
    INVALID_CURRENT_PASSWORD("현재 비밀번호가 일치하지 않습니다."),
    NO_NEW_PASSWORD_PROVIDED("현재와 동일한 비밀번호 입니다."),
    DUPLICATE_LOGIN_ID("이미 사용 중인 로그인 ID 입니다."),
    DUPLICATE_VALUE("다른 유저가 이미 사용 중인 값 입니다."),
    FAILED_NOTIFICATION("알림 전송에 실패했습니다."),
    NOT_VALID_INPUT("중복되는 값이 있거나, 형식에 맞지 않는 값이 있습니다."),
    DUPLICATE_MAPPING("이미 자녀로 연결되어 있습니다"),
    NOT_NEW_VALUE("변경하려는 값이 기존의 값과 동일 합니다."),
    NOT_ALLOW("본인 또는 본인에게 등록된 자녀의 정보만 수정할 수 있습니다"),
    SHARE_USER_NOT_FOUND("공유자의 Login_Id가 잘못되었습니다.");



    private final String message;
}
