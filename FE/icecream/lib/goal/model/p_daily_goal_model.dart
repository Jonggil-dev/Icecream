class PDailyGoal {
  final Map<DateTime, int> data;

  PDailyGoal(this.data);

  factory PDailyGoal.fromJson(Map<String, dynamic> json) {
    Map<DateTime, int> data = {};
    if (json['data'] != null) {
      json['data'].forEach((key, value) {
        data[DateTime.parse(key)] = value;
      });
    }
    return PDailyGoal(data);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    data.forEach((key, value) {
      json[key.toString()] = value;
    });
    return {'data': json};
  }
}