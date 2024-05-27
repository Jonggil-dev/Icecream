package com.example.icecream.domain.map.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class GpsResponseDto {

    private Integer userId;
    private Double latitude;
    private Double longitude;
    private String destinationId;
    private String timestamp;
}
