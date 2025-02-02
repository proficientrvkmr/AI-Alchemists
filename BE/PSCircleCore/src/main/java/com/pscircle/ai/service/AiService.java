package com.pscircle.ai.service;

import com.pscircle.ai.models.SurveyQuestion;
import com.pscircle.ai.models.response.SurveyResponse;
import com.pscircle.ai.service.interfaces.IAiService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AiService implements IAiService {

    @Override
    public SurveyQuestion generateQuestion(String userId, List<SurveyResponse> responses) {
        // Generate question based on responses
        return null;
    }

    @Override
    public String generateGist(String userId, List<SurveyResponse> responses) {
        // Generate gist based on responses
        return null;
    }
}
