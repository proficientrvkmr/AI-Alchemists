package com.pscircle.ai.service;

import com.pscircle.ai.models.SurveyQuestion;
import com.pscircle.ai.models.User;
import com.pscircle.ai.models.response.SurveyResponse;
import com.pscircle.ai.respository.UserRepository;
import com.pscircle.ai.service.interfaces.IAiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class SurveyService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private IAiService aiService;

    private final int MAX_QUESTIONS = 15;

    public SurveyQuestion startSurvey(String userId) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) {
            throw new IllegalArgumentException("User not found with id: " + userId);
        }

        User user = userOptional.get();
        user.setSurveyResponses(new ArrayList<>());
        userRepository.save(user);

        return aiService.generateQuestion(userId, user.getSurveyResponses());
    }

    public SurveyQuestion answerQuestion(String userId, SurveyResponse response) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) {
            throw new IllegalArgumentException("User not found with id: " + userId);
        }

        User user = userOptional.get();
        List<SurveyResponse> responses = user.getSurveyResponses();
        responses.add(response);
        userRepository.save(user);

        if (responses.size() >= MAX_QUESTIONS) {
            return null; // Survey ends after max questions
        }

        return aiService.generateQuestion(userId, responses);
    }

    public String endSurvey(String userId) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) {
            throw new IllegalArgumentException("User not found with id: " + userId);
        }

        User user = userOptional.get();
        List<SurveyResponse> responses = user.getSurveyResponses();
        String gist = aiService.generateGist(userId, responses);

        user.setEmotionalIntelligenceGist(gist);
        userRepository.save(user);

        return gist;
    }
}