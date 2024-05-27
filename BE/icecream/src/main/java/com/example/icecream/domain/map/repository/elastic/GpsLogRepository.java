package com.example.icecream.domain.map.repository.elastic;

import com.example.icecream.domain.map.entity.GpsLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GpsLogRepository extends ElasticsearchRepository<GpsLog, String> {

    Page<GpsLog> findByUserId(Integer userId, Pageable pageable);
}
