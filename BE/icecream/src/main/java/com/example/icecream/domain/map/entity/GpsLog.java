package com.example.icecream.domain.map.entity;

import lombok.Getter;
import org.springframework.data.annotation.Id;
import org.springframework.data.elasticsearch.annotations.DateFormat;
import org.springframework.data.elasticsearch.annotations.Document;
import org.springframework.data.elasticsearch.annotations.Field;
import org.springframework.data.elasticsearch.annotations.FieldType;

import java.util.Date;

@Getter
@Document(indexName = "gps-logs-*")
public class GpsLog {

    @Id
    private String id;

    @Field(type = FieldType.Keyword)
    private Integer userId;

    @Field(type = FieldType.Double)
    private Double latitude;

    @Field(type = FieldType.Double)
    private Double longitude;

    @Field(type = FieldType.Keyword)
    private String destinationId;

    @Field(name = "@timestamp", type = FieldType.Date, format = DateFormat.date_time)
    private Date timestamp;
}
