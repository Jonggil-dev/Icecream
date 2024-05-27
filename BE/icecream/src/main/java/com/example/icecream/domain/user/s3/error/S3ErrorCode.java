package com.example.icecream.domain.user.s3.error;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum S3ErrorCode {

    Image_NOT_FOUND("Request MultipartFile 객체에 Image 정보가 없습니다."),
    NO_FILE_EXTENTION("파일 확장자가 없습니다. 파일 확장자를 포함해 주세요."),
    INVALID_FILE_EXTENTION("허용되지 않는 파일 확장자입니다. 허용되는 확장자는 jpg, jpeg, png, gif 입니다."),
    EXCEPTION_ON_IMAGE_UPLOAD("이미지 업로드에 실패했습니다."),
    PUT_OBJECT_EXCEPTION("S3에 파일 업로드를 진행하는 중 에러가 발생했습니다."),
    IO_EXCEPTION_ON_IMAGE_DELETE("이미지 삭제 중 입출력 오류가 발생했습니다"),
    UPLOAD_ROLLBACK_ERROR("요청된 이미지가 S3에 업로드 되었으나 롤백(삭제)에 실패했습니다.");

    private final String message;
}
