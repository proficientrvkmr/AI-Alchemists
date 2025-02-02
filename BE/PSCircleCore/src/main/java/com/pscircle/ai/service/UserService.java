package com.pscircle.ai.service;

import com.pscircle.ai.exception.CustomBusinessException;
import com.pscircle.ai.models.Interest;
import com.pscircle.ai.models.User;
import com.pscircle.ai.models.commons.WorkflowState;
import com.pscircle.ai.models.request.UpdateUserDataRequest;
import com.pscircle.ai.models.request.UserDataRequest;
import com.pscircle.ai.respository.InterestRepository;
import com.pscircle.ai.respository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private InterestRepository interestRepository;

    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByUserEmail(email);
    }

    public User createUser(UserDataRequest userDataRequest) {
        if (userDataRequest.getUserEmail() == null) {
            throw new IllegalArgumentException("User email is required");
        }
        if (userRepository.findByUserEmail(userDataRequest.getUserEmail()).isPresent()) {
            throw new CustomBusinessException("User with email already exists", HttpStatus.CONFLICT);
        }
        User user = new User();
        user.setId(UUID.randomUUID().toString());
        user.setUserEmail(userDataRequest.getUserEmail());
        user.setCreatedOn(LocalDateTime.now());
        user.setUpdatedOn(LocalDateTime.now());
        user.setCurrentWorkflowStateCode(WorkflowState.INTERESTS.name());
        user.setNextWorkflowStateCode(WorkflowState.ASPIRATIONS.name());
        return userRepository.save(user);
    }

    public Optional<User> updateUser(String userId, UpdateUserDataRequest updateDataRequest) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) {
            throw new CustomBusinessException("User not found with id: " + userId, HttpStatus.NOT_FOUND);
        }

        User user = userOptional.get();
        user.setUpdatedOn(LocalDateTime.now());

        updateInterests(user, updateDataRequest.getInterests());
        updateAspirations(user, updateDataRequest.getAspirations());
        updateEmotionalIntelligenceGist(user, updateDataRequest.getEmotionalIntelligenceGist());
        updateUserBio(user, updateDataRequest.getUserBio());
        updateSkills(user, updateDataRequest.getSkills());
        updateKarmaPoints(user, updateDataRequest.getKarmaPoints());
        updateWorkflowStates(user, updateDataRequest.getCurrentWorkflowStateCode(), updateDataRequest.getNextWorkflowStateCode());

        return Optional.of(userRepository.save(user));
    }

    private void updateInterests(User user, List<String> interests) {
        if (interests != null) {
            List<String> interestIds = interests.stream()
                    .map(interestName -> interestRepository.findByName(interestName)
                            .map(Interest::getId).orElse(null))
                    .filter(id -> id != null)
                    .collect(Collectors.toList());

            user.setInterests(interestIds);
            transitionWorkflowState(user, WorkflowState.INTERESTS);
        }
    }

    private void updateAspirations(User user, String aspirations) {
        if (aspirations != null) {
            user.setAspirations(aspirations);
            transitionWorkflowState(user, WorkflowState.ASPIRATIONS);
        }
    }

    private void updateEmotionalIntelligenceGist(User user, String emotionalIntelligenceGist) {
        if (emotionalIntelligenceGist != null) {
            user.setEmotionalIntelligenceGist(emotionalIntelligenceGist);
            transitionWorkflowState(user, WorkflowState.EMOTIONAL_INTELLIGENCE);
        }
    }

    private void updateUserBio(User user, String userBio) {
        if (userBio != null) {
            user.setUserBio(userBio);
            transitionWorkflowState(user, WorkflowState.ABOUT);
        }
    }

    private void updateSkills(User user, List<String> skills) {
        if (skills != null) {
            user.setSkills(skills);
        }
    }

    private void updateKarmaPoints(User user, int karmaPoints) {
        if (karmaPoints != 0) {
            user.setKarmaPoints(karmaPoints);
        }
    }

    private void updateWorkflowStates(User user, String currentWorkflowStateCode, String nextWorkflowStateCode) {
        if (currentWorkflowStateCode != null) {
            user.setCurrentWorkflowStateCode(currentWorkflowStateCode);
        }
        if (nextWorkflowStateCode != null) {
            user.setNextWorkflowStateCode(nextWorkflowStateCode);
        }
    }

    private void transitionWorkflowState(User user, WorkflowState currentState) {
        if (user.getNextWorkflowStateCode() != null && user.getNextWorkflowStateCode().equals(currentState.name())) {
            user.setCurrentWorkflowStateCode(currentState.name());
            switch (currentState) {
                case INTERESTS:
                    user.setNextWorkflowStateCode(WorkflowState.ASPIRATIONS.name());
                    break;
                case ASPIRATIONS:
                    user.setNextWorkflowStateCode(WorkflowState.EMOTIONAL_INTELLIGENCE.name());
                    break;
                case EMOTIONAL_INTELLIGENCE:
                    user.setNextWorkflowStateCode(WorkflowState.ABOUT.name());
                    break;
                case ABOUT:
                    user.setNextWorkflowStateCode(WorkflowState.ONBOARDED.name());
                    break;
                case ONBOARDED:
                    user.setNextWorkflowStateCode(null);
                    break;
                default:
                    throw new IllegalStateException("Unexpected value: " + currentState);
            }
        }
    }
}