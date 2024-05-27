class CrossWalk {
  int? status;
  String? message;
  Map<String, int>? data;

  CrossWalk({this.status, this.message, this.data});

  CrossWalk.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = Map<String, int>.from(json['data']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data;
    }
    return data;
  }

  Map<String, bool> get result {
    if (data == null) {
      return {};
    }
    return data!.map((key, value) => MapEntry(key, value == 1));
  }
}
