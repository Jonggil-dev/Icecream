package com.example.icecream.domain.map.service;

import com.example.icecream.domain.map.dto.DestinationModifyDto;
import com.example.icecream.domain.map.dto.DestinationRegisterDto;
import com.example.icecream.domain.map.dto.DestinationResponseDto;

import java.util.List;

public interface DestinationService {

    List<DestinationResponseDto> getDestinations(Integer userId, Integer childId);
    void registerDestination(Integer userId, DestinationRegisterDto destinationRegisterDto);
    void modifyDestination(Integer userId, DestinationModifyDto destinationModifyDto);
    void deleteDestination(Integer userId, Integer destinationId);
}
