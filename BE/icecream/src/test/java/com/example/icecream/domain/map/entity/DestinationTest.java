package com.example.icecream.domain.map.entity;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class DestinationTest {

        @Test
        void destinationBuilderTest() {
            Destination destination = Destination.builder()
                    .userId(1)
                    .name("testDestination")
                    .latitude(1.0)
                    .longitude(1.0)
                    .build();

            assertEquals(1, destination.getUserId());
            assertEquals("testDestination", destination.getName());
            assertEquals(1.0, destination.getLatitude());
            assertEquals(1.0, destination.getLongitude());
        }
}