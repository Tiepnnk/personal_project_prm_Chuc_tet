import 'package:personal_project_prm/data/dto/login/login_request_dto.dart';
import 'package:personal_project_prm/data/dto/login/login_response_dto.dart';

import 'package:personal_project_prm/data/dto/register/register_request_dto.dart';

abstract class IAuthApi {
  Future<LoginResponseDto> login(LoginRequestDto request);
  Future<void> register(RegisterRequestDto request);

  Future<LoginResponseDto?> getCurrentSession();
  Future<void> updateAvatar(int userId, String avatarPath);
  Future<void> logout();
}
