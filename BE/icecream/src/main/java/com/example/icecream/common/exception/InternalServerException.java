package com.example.icecream.common.exception;

public class InternalServerException extends RuntimeException{

    public InternalServerException(String message) {
        super(message);
    }
}
