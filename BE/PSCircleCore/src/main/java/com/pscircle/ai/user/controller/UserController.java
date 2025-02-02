package com.pscircle.ai.user.controller;

import com.pscircle.ai.user.models.User;
import com.pscircle.ai.user.models.request.UpdateUserDataRequest;
import com.pscircle.ai.user.models.request.UserDataRequest;
import com.pscircle.ai.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


import java.util.Optional;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @Autowired
    private UserService userService; // Inject the service

    @GetMapping("/userData")
    public ResponseEntity<User> getUserData(@RequestParam String email) {
        Optional<User> user = userService.getUserByEmail(email);
        return user.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/userData")
    public ResponseEntity<User> postUserData(@Valid @RequestBody UserDataRequest userDataRequest) {
        User createdUser = userService.createUser(userDataRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
    }

    @PostMapping("/userData/{userId}")
    public ResponseEntity<User> updateUserData(@PathVariable String userId, @RequestBody UpdateUserDataRequest updateDataRequest) {
        Optional<User> updatedUser = userService.updateUser(userId, updateDataRequest);
        return updatedUser.map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
