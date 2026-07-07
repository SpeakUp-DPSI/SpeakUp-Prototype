class FollowUpModel {
  final int id;
  final int reportId;
  final int executorId;
  final String actionTaken;
  final DateTime? followUpDate;
  final String? reportCode;
  final String? executorName;

  FollowUpModel({
    required this.id,
    required this.reportId,
    required this.executorId,
    required this.actionTaken,
    this.followUpDate,
    this.reportCode,
    this.executorName,
  });

  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    return FollowUpModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      reportId: json['report_id'] is int ? json['report_id'] : int.tryParse(json['report_id'].toString()) ?? 0,
      executorId: json['executor_id'] is int ? json['executor_id'] : int.tryParse(json['executor_id'].toString()) ?? 0,
      actionTaken: json['action_taken']?.toString() ?? '',
      followUpDate: json['follow_up_date'] != null ? DateTime.tryParse(json['follow_up_date'].toString()) : null,
      reportCode: json['report']?['report_code']?.toString(),
      executorName: json['executor']?['name']?.toString(),
    );
  }
}
