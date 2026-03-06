import 'package:personal_project_prm/domain/entities/auth_session.dart';

abstract class IAuthRepository{
  Future<AuthSession> login(String userName, String password);
  Future<void> register({
    required String userName,
    required String password,
    String? phone,
    String? fullName,
  });

  Future<AuthSession?> getCurrentSession();
  Future<void> logout();
  Future<void> updateAvatar(String avatarPath);
}