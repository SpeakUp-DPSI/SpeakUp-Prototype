class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var rolesList = <String>[];
    if (json['roles'] != null) {
      rolesList = (json['roles'] as List).map((role) => role['name'].toString()).toList();
    }

    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      roles: rolesList,
    );
  }
}
