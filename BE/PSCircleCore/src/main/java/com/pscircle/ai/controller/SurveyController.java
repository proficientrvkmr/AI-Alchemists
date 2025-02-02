package com.pscircle.ai.controller;

import com.pscircle.ai.models.SurveyQuestion;
import com.pscircle.ai.models.response.SurveyResponse;
import com.pscircle.ai.service.SurveyService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/survey")
public class SurveyController {

    @Autowired
    private SurveyService surveyService;

    @PostMapping("/start")
    public ResponseEntity<SurveyQuestion> startSurvey(@RequestParam String userId) {
        return ResponseEntity.ok(surveyService.startSurvey(userId));
    }

    @PostMapping("/answer")
    public ResponseEntity<SurveyQuestion> answerQuestion(@RequestParam String userId, @Valid @RequestBody SurveyResponse response) {
        return ResponseEntity.ok(surveyService.answerQuestion(userId, response)); // Simplified
    }

    @PostMapping("/end")
    public ResponseEntity<String> endSurvey(@RequestParam String userId) {
        return ResponseEntity.ok(surveyService.endSurvey(userId)); // Simplified
    }
}