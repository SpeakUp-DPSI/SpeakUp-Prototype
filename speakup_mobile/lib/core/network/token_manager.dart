import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'auth_user_data';
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Persist user data as a JSON string alongside the token.
  Future<void> saveUserData(String userDataJson) async {
    await _storage.write(key: _userDataKey, value: userDataJson);
  }

  /// Retrieve persisted user data JSON.
  Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  /// Remove persisted user data.
  Future<void> removeUserData() async {
    await _storage.delete(key: _userDataKey);
  }
}
