class MediationModel {
  final int id;
  final int reportId;
  final int mediatorId;
  final DateTime scheduleDate;
  final String location;
  final String status;
  final String? result;
  final String? reportCode;
  final String? mediatorName;
  final List<MediationParticipantModel> participants;

  MediationModel({
    required this.id,
    required this.reportId,
    required this.mediatorId,
    required this.scheduleDate,
    required this.location,
    required this.status,
    this.result,
    this.reportCode,
    this.mediatorName,
    this.participants = const [],
  });

  factory MediationModel.fromJson(Map<String, dynamic> json) {
    return MediationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      reportId: json['report_id'] is int ? json['report_id'] : int.tryParse(json['report_id'].toString()) ?? 0,
      mediatorId: json['mediator_id'] is int ? json['mediator_id'] : int.tryParse(json['mediator_id'].toString()) ?? 0,
      scheduleDate: DateTime.parse(json['schedule_date']),
      location: json['location'] ?? '',
      status: json['status'] ?? 'scheduled',
      result: json['result']?.toString(),
      reportCode: json['report']?['report_code']?.toString(),
      mediatorName: json['mediator']?['name']?.toString(),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => MediationParticipantModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MediationParticipantModel {
  final int id;
  final int userId;
  final String status;
  final String? userName;

  MediationParticipantModel({
    required this.id,
    required this.userId,
    required this.status,
    this.userName,
  });

  factory MediationParticipantModel.fromJson(Map<String, dynamic> json) {
    return MediationParticipantModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      status: json['status'] ?? 'pending',
      userName: json['user']?['name']?.toString(),
    );
  }
}
