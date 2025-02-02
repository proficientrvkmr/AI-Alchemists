package com.pscircle.ai.respository;

import com.pscircle.ai.models.Interest;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface InterestRepository extends MongoRepository<Interest, String> {
    Optional<Interest> findByName(String name);
}