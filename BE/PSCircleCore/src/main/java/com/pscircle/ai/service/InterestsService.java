package com.pscircle.ai.service;

import com.pscircle.ai.models.Interest;
import com.pscircle.ai.respository.InterestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class InterestsService {

    @Autowired
    InterestRepository interestRepository;

    public List<Interest> listInterests() {
        return interestRepository.findAll();
    }
}
