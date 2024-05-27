package com.example.icecream.domain.map.entity;

import com.example.icecream.common.entity.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.locationtech.jts.geom.Point;

import java.time.LocalTime;

@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Getter
@Builder
@Table(name = "destination")
public class Destination extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", nullable = false)
    @NotNull
    private Integer userId;

    @Column(name = "name", nullable = false, length = 20)
    @NotNull
    private String name;

    @Column(name = "icon", nullable = false)
    @NotNull
    private Integer icon;

    @Column(name = "latitude", nullable = false)
    @NotNull
    private Double latitude;

    @Column(name = "longitude", nullable = false)
    @NotNull
    private Double longitude;

    @Column(name = "address", nullable = false, length = 100)
    @NotNull
    private String address;

    @Column(name = "start_time", nullable = false)
    @NotNull
    private LocalTime startTime;

    @Column(name = "end_time", nullable = false)
    @NotNull
    private LocalTime endTime;

    @Column(name = "day", nullable = false, length = 7)
    @NotNull
    private String day;

    @Column(name = "location", nullable = false, columnDefinition = "geography(Point, 4326)")
    @NotNull
    private Point location;

    @Column(name = "radius", nullable = false)
    @NotNull
    private Double radius = 100.0;

    public void updateDestination(String name, Integer icon, Double latitude, Double longitude, String address,
                                  LocalTime startTime, LocalTime endTime, String day, Point location) {
        this.name = name;
        this.icon = icon;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.startTime = startTime;
        this.endTime = endTime;
        this.day = day;
        this.location = location;
    }
}
