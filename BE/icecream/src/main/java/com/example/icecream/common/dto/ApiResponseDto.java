package com.example.icecream.common.dto;

import lombok.Getter;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;

@Getter
@AllArgsConstructor
public class ApiResponseDto<T> {

    private int status;
    private String message;
    private T data;

    public static <T> ResponseEntity<ApiResponseDto<T>> success(String message, T data) {
        ApiResponseDto<T> response = new ApiResponseDto<>(200, message, data);
        return ResponseEntity.status(200).body(response);
    }

    public static <T> ResponseEntity<ApiResponseDto<T>> success(String message) {
        ApiResponseDto<T> response = new ApiResponseDto<>(200, message, null);
        return ResponseEntity.status(200).body(response);
    }

    public static <T> ResponseEntity<ApiResponseDto<T>> created(String message) {
        ApiResponseDto<T> response = new ApiResponseDto<>(201, message, null);
        return ResponseEntity.status(201).body(response);
    }

    public static <T> ResponseEntity<ApiResponseDto<T>> badRequest(String message) {
        ApiResponseDto<T> response = new ApiResponseDto<>(400, message, null);
        return ResponseEntity.status(400).body(response);
    }

    public static <T> ResponseEntity<ApiResponseDto<T>> unauthorized(String message) {
        ApiResponseDto<T> response = new ApiResponseDto<>(401, message, null);
        return ResponseEntity.status(401).body(response);
    }

    public static <T> ResponseEntity<ApiResponseDto<T>> forbidden(String message) {
        ApiResponseDto<T> response = new ApiResponseDto<>(403, message, null);
        return ResponseEntity.status(403).body(response);
    }

    public static <T> ResponseEntity<ApiResponseDto<T>> notFound(String message) {
        ApiResponseDto<T> response = new ApiResponseDto<>(404, message, null);
        return ResponseEntity.status(404).body(response);
    }

    public static <T> ResponseEntity<ApiResponseDto<T>> conflict(String message) {
        ApiResponseDto<T> response = new ApiResponseDto<>(409, message, null);
        return ResponseEntity.status(409).body(response);
    }

    public static <T> ResponseEntity<ApiResponseDto<T>> error(String errorMessage) {
        ApiResponseDto<T> response = new ApiResponseDto<>(500, "서버 에러 발생: " + errorMessage, null);
        return ResponseEntity.status(500).body(response);
    }
}