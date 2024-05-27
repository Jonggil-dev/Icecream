package com.example.icecream.domain.map.service;

import com.example.icecream.common.exception.BadRequestException;
import com.example.icecream.common.exception.DataAccessException;
import com.example.icecream.common.exception.DataConflictException;
import com.example.icecream.common.exception.NotFoundException;
import com.example.icecream.domain.map.dto.DestinationModifyDto;
import com.example.icecream.domain.map.dto.DestinationRegisterDto;
import com.example.icecream.domain.map.dto.DestinationResponseDto;
import com.example.icecream.domain.map.entity.Destination;
import com.example.icecream.domain.map.error.MapErrorCode;
import com.example.icecream.domain.map.repository.DestinationRepository;
import com.example.icecream.domain.user.util.UserValidationUtils;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.util.List;

@Transactional(readOnly = true)
@Service
public class DestinationServiceImpl implements DestinationService {

    private final DestinationRepository destinationRepository;
    private final GeometryFactory geometryFactory = new GeometryFactory();
    private final UserValidationUtils userValidationUtils;

    public DestinationServiceImpl(UserValidationUtils userValidationUtils,
                                  DestinationRepository destinationRepository) {
        this.destinationRepository = destinationRepository;
        this.userValidationUtils = userValidationUtils;
    }

    @Override
    public List<DestinationResponseDto> getDestinations(Integer userId, Integer childId) {
        if (!userValidationUtils.isUserExist(childId)) {
            throw new NotFoundException(MapErrorCode.USER_NOT_FOUND.getMessage());
        }

        if (!userValidationUtils.isParentUserWithPermission(userId, childId) && !userId.equals(childId)) {
            throw new DataAccessException(MapErrorCode.GET_DESTINATION_ACCESS_DENIED.getMessage());
        }

        return destinationRepository.findAllByUserId(childId)
                .stream()
                .map(destination -> new DestinationResponseDto(
                        destination.getId(),
                        destination.getName(),
                        destination.getIcon(),
                        destination.getLatitude(),
                        destination.getLongitude(),
                        destination.getAddress(),
                        destination.getStartTime(),
                        destination.getEndTime(),
                        destination.getDay()
                ))
                .toList();
    }

    @Override
    @Transactional
    public void registerDestination(Integer userId, DestinationRegisterDto destinationRegisterDto) {
        if (!userValidationUtils.isParentUserWithPermission(userId, destinationRegisterDto.getUserId())) {
            throw new DataAccessException(MapErrorCode.REGISTER_DESTINATION_ACCESS_DENIED.getMessage());
        }

        validateDestinationDetails(destinationRegisterDto.getDay(), destinationRegisterDto.getStartTime(), destinationRegisterDto.getEndTime());

        checkDestinationOverlap(null, destinationRegisterDto.getUserId(), destinationRegisterDto.getDay(),
                destinationRegisterDto.getStartTime(), destinationRegisterDto.getEndTime());

        Point location = geometryFactory.createPoint(
                new Coordinate(destinationRegisterDto.getLongitude(),
                        destinationRegisterDto.getLatitude()));

        Destination destination = Destination.builder()
                .userId(destinationRegisterDto.getUserId())
                .name(destinationRegisterDto.getName())
                .icon(destinationRegisterDto.getIcon())
                .latitude(destinationRegisterDto.getLatitude())
                .longitude(destinationRegisterDto.getLongitude())
                .address(destinationRegisterDto.getAddress())
                .startTime(destinationRegisterDto.getStartTime())
                .endTime(destinationRegisterDto.getEndTime())
                .day(destinationRegisterDto.getDay())
                .location(location)
                .radius(100.0)
                .build();

        destinationRepository.save(destination);
    }

    @Override
    @Transactional
    public void modifyDestination(Integer userId, DestinationModifyDto destinationModifyDto) {
        Destination destination = destinationRepository.findById(destinationModifyDto.getDestinationId())
                .orElseThrow(() -> new NotFoundException(MapErrorCode.DESTINATION_NOT_FOUND.getMessage()));

        if (!userValidationUtils.isParentUserWithPermission(userId, destination.getUserId())) {
            throw new DataAccessException(MapErrorCode.MODIFY_DESTINATION_ACCESS_DENIED.getMessage());
        }

        validateDestinationDetails(destinationModifyDto.getDay(), destinationModifyDto.getStartTime(), destinationModifyDto.getEndTime());

        checkDestinationOverlap(destinationModifyDto.getDestinationId(), destination.getUserId(), destinationModifyDto.getDay(),
                destinationModifyDto.getStartTime(), destinationModifyDto.getEndTime());

        Point location = geometryFactory.createPoint(
                new Coordinate(destinationModifyDto.getLongitude(),
                        destinationModifyDto.getLatitude()));

        destination.updateDestination(destinationModifyDto.getName(), destinationModifyDto.getIcon(),
                destinationModifyDto.getLatitude(), destinationModifyDto.getLongitude(), destinationModifyDto.getAddress(),
                destinationModifyDto.getStartTime(), destinationModifyDto.getEndTime(),
                destinationModifyDto.getDay(), location);

        destinationRepository.save(destination);
    }

    @Override
    @Transactional
    public void deleteDestination(Integer userId, Integer destinationId) {
        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new NotFoundException(MapErrorCode.DESTINATION_NOT_FOUND.getMessage()));

        if (!userValidationUtils.isParentUserWithPermission(userId, destination.getUserId())) {
            throw new DataAccessException(MapErrorCode.DELETE_DESTINATION_ACCESS_DENIED.getMessage());
        }

        destinationRepository.delete(destination);
    }

    private void validateDestinationDetails(String day, LocalTime startTime, LocalTime endTime) {
        if (startTime.isAfter(endTime)) {
            throw new BadRequestException(MapErrorCode.DESTINATION_TIME_INVALID.getMessage());
        }
        if (day.length() != 7 || day.equals("0000000") || !day.matches("[01]{7}")) {
            throw new BadRequestException(MapErrorCode.DESTINATION_DAY_INVALID.getMessage());
        }
    }

    private void checkDestinationOverlap(Integer destinationId, Integer userId, String day, LocalTime startTime, LocalTime endTime) {
        List<Destination> overlappingDestinations = destinationRepository.findOverlappingDestinationsByTime(userId, destinationId, startTime, endTime);

        for (Destination destination : overlappingDestinations) {
            if (daysOverlap(destination.getDay(), day)) {
                throw new DataConflictException(MapErrorCode.DESTINATION_OVERLAP.getMessage());
            }
        }
    }

    private boolean daysOverlap(String existingDays, String newDays) {
        for (int i = 0; i < 7; i++) {
            if (existingDays.charAt(i) == '1' && newDays.charAt(i) == '1') {
                return true;
            }
        }
        return false;
    }
}
