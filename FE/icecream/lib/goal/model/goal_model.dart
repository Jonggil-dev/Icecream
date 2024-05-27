class DailyGoal {
  final int period;
  final int record;
  final String content;
  final Map<String, bool> result;

  DailyGoal(
      {required this.period,
      required this.record,
      required this.content,
      required this.result});

  factory DailyGoal.fromJson(Map<String, dynamic> json) {
    return DailyGoal(
      period: json['period'] as int,
      record: json['record'] as int,
      content: json['content'] as String,
      result: Map<String, bool>.from(json['result']),
    );
  }
}
