package com.pscircle.ai.models;

import com.pscircle.ai.models.response.SurveyResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.List;

@Document("users")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class User {

    @Id
    private String id; // userIdCreated (UUID)
    private String userEmail;
    private String userBio;
    private String currentWorkflowStateCode;
    private String nextWorkflowStateCode;
    private int karmaPoints;
    private String aspirations;
    private List<String> skills;
    private String emotionalIntelligenceGist;
    private List<SurveyResponse> surveyResponses;
    private List<String> interests;
    private LocalDateTime createdOn;
    private LocalDateTime updatedOn;
    private boolean deactivated;
}