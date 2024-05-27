package com.example.icecream.domain.map.repository;

import com.example.icecream.domain.map.entity.Crosswalk;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CrosswalkRepository extends JpaRepository<Crosswalk, Integer> {
}
