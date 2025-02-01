package com.pscircle.ai.controller;

import com.pscircle.ai.models.Interest;
import com.pscircle.ai.service.InterestsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class InterestsController {

    @Autowired
    private InterestsService interestsService;

    @GetMapping("/interests/list")
    private List<Interest> listInterests() {
        return interestsService.listInterests();
    }
}
