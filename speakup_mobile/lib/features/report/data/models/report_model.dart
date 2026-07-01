class ReportModel {
  final int id;
  final String reportCode;
  final String title;
  final String description;
  final String status; // 'Menunggu Validasi', 'Diproses', 'Selesai', 'Ditolak'
  final String? incidentLocation;
  final String? incidentDate;
  final String? category;
  final bool isAnonymous;
  final String? bkNote;
  final String? reporterId;
  final String? reportedId;

  ReportModel({
    required this.id,
    required this.reportCode,
    required this.title,
    required this.description,
    required this.status,
    this.incidentLocation,
    this.incidentDate,
    this.category,
    this.isAnonymous = false,
    this.bkNote,
    this.reporterId,
    this.reportedId,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      reportCode: json['report_code']?.toString() ?? 'SPK-${json['id']}',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'submitted',
      incidentLocation: json['incident_location']?.toString(),
      incidentDate: json['incident_date']?.toString(),
      category: json['category']?.toString(),
      isAnonymous: json['is_anonymous'] == true || json['is_anonymous'] == 1,
      bkNote: json['bk_note']?.toString(),
      reporterId: json['reporter_id']?.toString(),
      reportedId: json['reported_id']?.toString(),
    );
  }

  ReportModel copyWith({
    int? id,
    String? reportCode,
    String? title,
    String? description,
    String? status,
    String? incidentLocation,
    String? incidentDate,
    String? category,
    bool? isAnonymous,
    String? bkNote,
    String? reporterId,
    String? reportedId,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reportCode: reportCode ?? this.reportCode,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      incidentLocation: incidentLocation ?? this.incidentLocation,
      incidentDate: incidentDate ?? this.incidentDate,
      category: category ?? this.category,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      bkNote: bkNote ?? this.bkNote,
      reporterId: reporterId ?? this.reporterId,
      reportedId: reportedId ?? this.reportedId,
    );
  }
}
