class AdminUserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? createdAt;

  const AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'siswa',
      createdAt: json['created_at']?.toString(),
    );
  }
}
