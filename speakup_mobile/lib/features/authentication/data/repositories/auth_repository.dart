import '../datasources/auth_remote_data_source.dart';
import '../../../../core/network/token_manager.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenManager tokenManager;

  AuthRepository(this.remoteDataSource, this.tokenManager);

  Future<UserModel> login(String email, String password) async {
    final result = await remoteDataSource.login(email, password);
    final token = result['token'] as String;
    final user = result['user'] as UserModel;

    await tokenManager.saveToken(token);
    
    return user;
  }

  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      // Proceed to remove token locally even if server fails
    } finally {
      await tokenManager.removeToken();
    }
  }

  Future<UserModel> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    return await remoteDataSource.updateProfile(data);
  }

  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    await remoteDataSource.updatePassword(currentPassword: currentPassword, newPassword: newPassword);
  }
}
