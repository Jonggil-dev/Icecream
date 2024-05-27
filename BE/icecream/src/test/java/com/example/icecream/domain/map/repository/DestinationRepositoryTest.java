package com.example.icecream.domain.map.repository;

import com.example.icecream.domain.map.entity.Destination;
import org.junit.jupiter.api.Test;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalTime;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
@ActiveProfiles("local")
class DestinationRepositoryTest {

    @Autowired
    private DestinationRepository destinationRepository;
    private final GeometryFactory geometryFactory = new GeometryFactory();

    @Test
    void testSaveDestination() {
         Point location = geometryFactory.createPoint(new Coordinate(1, 1));
         Destination destination = Destination.builder()
                 .userId(10)
                 .name("testDestination")
                 .icon(1)
                 .latitude(1.0)
                 .longitude(1.0)
                 .startTime(LocalTime.parse("09:00:00"))
                 .endTime(LocalTime.parse("18:00:00"))
                 .day("1111111")
                 .location(location)
                 .radius(1.0)
                 .build();
         Destination savedDestination = destinationRepository.save(destination);
         assertEquals(10, savedDestination.getUserId());
         assertEquals("testDestination", savedDestination.getName());
         assertEquals(1.0, savedDestination.getLatitude());
         assertEquals(1.0, savedDestination.getLongitude());
         assertEquals(LocalTime.parse("09:00:00"), savedDestination.getStartTime());
         assertEquals(LocalTime.parse("18:00:00"), savedDestination.getEndTime());
         assertEquals("1111111", savedDestination.getDay());
         assertEquals(location, savedDestination.getLocation());
         assertEquals(1.0, savedDestination.getRadius());
    }
}