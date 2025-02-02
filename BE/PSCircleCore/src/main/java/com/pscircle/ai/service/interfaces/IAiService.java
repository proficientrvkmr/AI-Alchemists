package com.pscircle.ai.service.interfaces;

import com.pscircle.ai.models.SurveyQuestion;
import com.pscircle.ai.models.response.SurveyResponse;

import java.util.List;

public interface IAiService {
    SurveyQuestion generateQuestion(String userId, List<SurveyResponse> responses);
    String generateGist(String userId, List<SurveyResponse> responses);
}
