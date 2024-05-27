package com.example.icecream.domain.map.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class DestinationRegisterDto {

    @NotNull(message = "user_id is required")
    private Integer userId;

    @NotNull(message = "name is required")
    private String name;

    @NotNull(message = "icon is required")
    private Integer icon;

    @NotNull(message = "latitude is required")
    private Double latitude;

    @NotNull(message = "longitude is required")
    private Double longitude;

    @NotNull(message = "address is required")
    private String address;

    @NotNull(message = "start_time is required")
    private LocalTime startTime;

    @NotNull(message = "end_time is required")
    private LocalTime endTime;

    @NotNull(message = "day is required")
    private String day;
}
