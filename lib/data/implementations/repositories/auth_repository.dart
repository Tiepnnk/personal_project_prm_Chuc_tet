import 'package:personal_project_prm/data/dto/login/login_request_dto.dart';
import 'package:personal_project_prm/data/dto/login/login_response_dto.dart';
import 'package:personal_project_prm/data/dto/register/register_request_dto.dart';
import 'package:personal_project_prm/data/implementations/api/auth_api.dart';
import 'package:personal_project_prm/data/interfaces/mapper/imapper.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iauth_repository.dart';
import 'package:personal_project_prm/domain/entities/auth_session.dart';

class AuthRepository implements IAuthRepository{
  final AuthApi api;
  final IMapper<LoginResponseDto,AuthSession> mapper;

  AuthRepository({required this.api, required this.mapper});

  @override
  Future<AuthSession> login(String userName, String password) async{
    final request = LoginRequestDto(userName: userName, password: password);
    final response = await api.login(request);
    return mapper.map(response);
  }

  @override
  Future<void> register({
    required String userName,
    required String password,
    String? phone,
    String? fullName,
  }) async {
    final request = RegisterRequestDto(
      userName: userName,
      password: password,
      phone: phone,
      fullName: fullName,
    );
    await api.register(request);
  }

  @override
  Future<AuthSession?> getCurrentSession() async{
    final dto = await api.getCurrentSession();
    if(dto == null) return null;
    return mapper.map(dto);
  }

  @override
  Future<void> logout() async{
    await api.logout();
  }

  @override
  Future<void> updateAvatar(String avatarPath) async {
    final session = await getCurrentSession();
    if (session != null) {
      final userId = session.user.id;
      await api.updateAvatar(userId, avatarPath);
    }
  }
}