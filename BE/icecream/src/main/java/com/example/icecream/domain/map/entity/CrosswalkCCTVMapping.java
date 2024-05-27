package com.example.icecream.domain.map.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Entity
@Table(name = "crosswalk_cctv_mapping")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Getter
@Builder
public class CrosswalkCCTVMapping {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "cctv_name", nullable = false, length = 20)
    @NotNull
    private String cctvName;

    @Column(name = "crosswalk_name", nullable = false, length = 20)
    @NotNull
    private String crosswalkName;
}
