class ValidationModel {
  final int id;
  final int reportId;
  final int validatorId;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final String? validatorName;

  ValidationModel({
    required this.id,
    required this.reportId,
    required this.validatorId,
    required this.status,
    this.notes,
    this.createdAt,
    this.validatorName,
  });

  factory ValidationModel.fromJson(Map<String, dynamic> json) {
    return ValidationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      reportId: json['report_id'] is int ? json['report_id'] : int.tryParse(json['report_id'].toString()) ?? 0,
      validatorId: json['validator_id'] is int ? json['validator_id'] : int.tryParse(json['validator_id'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      validatorName: json['validator']?['name']?.toString(),
    );
  }
}
