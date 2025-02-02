package com.pscircle.ai.exception;

import org.springframework.http.HttpStatus;

public class CustomBusinessException extends RuntimeException {
    private final HttpStatus status;
    private final String message;

    public CustomBusinessException(String message, HttpStatus status) {
        super(message);
        this.status = status;
        this.message = message;
    }

    public HttpStatus getStatus() {
        return status;
    }

    @Override
    public String getMessage() {
        return message;
    }
}