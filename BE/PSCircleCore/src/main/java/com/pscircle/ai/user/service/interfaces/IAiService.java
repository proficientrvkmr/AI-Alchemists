package com.pscircle.ai.user.service.interfaces;

import com.pscircle.ai.user.models.SurveyQuestion;
import com.pscircle.ai.user.models.response.SurveyResponse;

import java.util.List;

public interface IAiService {
    SurveyQuestion generateQuestion(String userId, List<SurveyResponse> responses);
    String generateGist(String userId, List<SurveyResponse> responses);
}
