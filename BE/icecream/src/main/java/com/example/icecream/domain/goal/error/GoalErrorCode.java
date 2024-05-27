package com.example.icecream.domain.goal.error;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum GoalErrorCode {

    REGISTER_GOAL_ACCESS_DENIED("목표 등록 권한이 없습니다."),
    REGISTER_GOAL_DUPLICATED("목표 등록이 중복되었습니다."),
    UPDATE_GOAL_ACCESS_DENIED("목표 수정 권한이 없습니다."),
    UPDATE_IS_NOT_ACTIVED_GOAL("활성화되지 않은 목표는 수정할 수 없습니다."),
    NOT_FOUND_GOAL("해당 목표가 존재하지 않습니다."),
    GET_GOAL_ACCESS_DENIED("목표 조회 권한이 없습니다."),
    REGISTER_GOAL_STATUS_DUPLICATED("목표 상태 등록이 중복되었습니다."),
    NOT_FOUND_GOAL_STATUS("해당 목표 상태가 존재하지 않습니다."),
    GET_FUTURE_GOAL_STATUS("미래 날짜의 목표 상태를 조회할 수 없습니다."),
    UPDATE_GOAL_STATUS_ACCESS_DENIED("목표 상태 수정 권한이 없습니다."),
    UPDATE_GOAL_STATUS_NOT_FOUND("해당 목표 상태가 존재하지 않습니다."),
    UPDATE_GOAL_OVER_RECORD("목표 달성 기록을 초과할 수 없습니다.");

    ;

    private final String message;
}
