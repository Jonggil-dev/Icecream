class NotificationModel {
  int? status;
  String? message;
  List<NotificationData>? data;

  NotificationModel({this.status, this.message, this.data});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      status: json['status'],
      message: json['message'],
      data: List<NotificationData>.from(
          json['data'].map((x) => NotificationData.fromJson(x))),
    );
  }
}

class NotificationData {
  String? datetime;
  String? content;

  NotificationData({this.datetime, this.content});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      datetime: json['datetime'],
      content: json['content'],
    );
  }
}
