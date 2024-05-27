class DailyGoal {
  final Map<DateTime, int> data;

  DailyGoal(this.data);

  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    Map<DateTime, int> data = {};
    if (json['data'] != null) {
      json['data'].forEach((key, value) {
        data[DateTime.parse(key)] = value;
      });
    }
    return DailyGoal(data);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    data.forEach((key, value) {
      json[key.toString()] = value;
    });
    return {'data': json};
  }
}