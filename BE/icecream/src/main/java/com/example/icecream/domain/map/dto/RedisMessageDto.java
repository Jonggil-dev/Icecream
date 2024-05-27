package com.example.icecream.domain.map.dto;

import lombok.Data;

import java.util.List;

@Data
public class RedisMessageDto {

    private String id;
    private List<Integer> content;
}
