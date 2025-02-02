package com.pscircle.ai.models.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UpdateUserDataRequest {
    private List<String> interests;
    private String currentWorkflowStateCode;
    private String nextWorkflowStateCode;
    private int karmaPoints;
    private String aspirations;
    private List<String> skills;
    private String emotionalIntelligenceGist;
    private String userBio;
}
