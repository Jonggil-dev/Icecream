class TimesetModel {
  int? status;
  String? message;
  List<Data>? data;

  TimesetModel({this.status, this.message, this.data});

  TimesetModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? destinationId;
  String? name;
  dynamic icon; // dynamic 타입으로 변경
  double? latitude; // 일반적으로 위도와 경도는 double 타입입니다.
  double? longitude;
  String? startTime;
  String? endTime;
  String? day;

  Data(
      {this.destinationId,
      this.name,
      this.icon,
      this.latitude,
      this.longitude,
      this.startTime,
      this.endTime,
      this.day});

  Data.fromJson(Map<String, dynamic> json) {
    destinationId = json['destination_id'];
    name = json['name'];
    icon = json['icon']; // 동적 타입 처리
    latitude = (json['latitude'] as num?)?.toDouble(); // 타입 캐스팅을 통해 double로 변환
    longitude =
        (json['longitude'] as num?)?.toDouble(); // 타입 캐스팅을 통해 double로 변환
    startTime = json['start_time'];
    endTime = json['end_time'];
    day = json['day'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['destination_id'] = destinationId;
    data['name'] = name;
    data['icon'] = icon; // 동적 타입 그대로 저장
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['day'] = day;
    return data;
  }
}
