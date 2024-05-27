package com.example.icecream.domain.map.repository;

import com.example.icecream.domain.map.entity.CrosswalkCCTVMapping;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CrosswalkCCTVMappingRepository extends JpaRepository<CrosswalkCCTVMapping, Integer> {
    CrosswalkCCTVMapping findCrosswalkCCTVMappingByCctvName(String cctvName);
}
