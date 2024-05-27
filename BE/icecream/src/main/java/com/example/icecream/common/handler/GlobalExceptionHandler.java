package com.example.icecream.common.handler;

import com.example.icecream.common.dto.ApiResponseDto;
import com.example.icecream.common.exception.*;
import jakarta.validation.ConstraintViolation;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.HandlerMethodValidationException;

import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ApiResponseDto<String>> handleNotFoundException(NotFoundException e) {
        return ApiResponseDto.notFound(e.getMessage());
    }

    @ExceptionHandler(InternalServerException.class)
    public ResponseEntity<ApiResponseDto<String>> handleInternalServerException(InternalServerException e) {
        return ApiResponseDto.error(e.getMessage());
    }

    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ApiResponseDto<String>> handleDataAccessException(DataAccessException e) {
        return ApiResponseDto.forbidden(e.getMessage());
    }

    @ExceptionHandler(DataConflictException.class)
    public ResponseEntity<ApiResponseDto<String>> handleDataConflictException(DataConflictException e) {
        return ApiResponseDto.conflict(e.getMessage());
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<ApiResponseDto<String>> handleBadRequestException(BadRequestException e) {
        return ApiResponseDto.badRequest(e.getMessage());
    }

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ApiResponseDto<String>> handleBadCredentialsException(BadCredentialsException e) {
        return ApiResponseDto.unauthorized(e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponseDto<String>> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        return ApiResponseDto.badRequest(e.getBindingResult().getAllErrors().get(0).getDefaultMessage());
    }

    @ExceptionHandler(HandlerMethodValidationException.class)
    public ResponseEntity<ApiResponseDto<String>> handleMethodValidationException(HandlerMethodValidationException e) {
        return ApiResponseDto.badRequest(e.getMessage());
    }
}
