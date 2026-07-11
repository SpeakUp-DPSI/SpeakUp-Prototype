// TODO: perlu endpoint backend belum tersedia — /api/admin/users (CRUD)

class AdminUserModel {
  final int id;
  final String name;
  final String email;
  final List<String> roles;
  final bool emailVerified;
  final String? phone;
  final String? className;
  final String? createdAt;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.emailVerified,
    this.phone,
    this.className,
    this.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    // Roles bisa berupa List<dynamic> berisi string atau List<Map> {name: ...}
    List<String> parseRoles(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((r) {
          if (r is String) return r;
          if (r is Map) return r['name']?.toString() ?? '';
          return '';
        }).where((s) => s.isNotEmpty).toList();
      }
      return [];
    }

    return AdminUserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roles: parseRoles(json['roles']),
      emailVerified: json['email_verified_at'] != null,
      phone: json['phone']?.toString(),
      className: json['class_name']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'roles': roles,
      };

  String get primaryRole => roles.isNotEmpty ? roles.first : 'siswa';

  String get roleLabel {
    switch (primaryRole) {
      case 'siswa':
        return 'Siswa';
      case 'guru_bk':
        return 'Guru BK';
      case 'kepsek':
        return 'Kepsek';
      case 'orangtua':
        return 'Orang Tua';
      case 'admin':
        return 'Admin';
      default:
        return primaryRole;
    }
  }
}
