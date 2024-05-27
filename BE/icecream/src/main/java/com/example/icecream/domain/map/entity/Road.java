package com.example.icecream.domain.map.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import org.locationtech.jts.geom.Polygon;

@Entity
@Getter
@Table(name = "road")
public class Road {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "road_area", nullable = false, columnDefinition = "geometry(Polygon, 4326)")
    @NotNull
    private Polygon roadArea;
}
