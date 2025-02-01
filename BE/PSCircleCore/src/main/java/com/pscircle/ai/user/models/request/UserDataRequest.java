package com.pscircle.ai.user.models.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class UserDataRequest {
    @NotNull(message = "User email is required")
    @Email(message = "User email should be valid")
    private String userEmail;
}