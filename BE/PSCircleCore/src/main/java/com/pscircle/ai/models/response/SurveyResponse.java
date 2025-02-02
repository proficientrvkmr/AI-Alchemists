package com.pscircle.ai.models.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class SurveyResponse {
    private String questionId;
    private int rating; // Rating from 1 to 5
}