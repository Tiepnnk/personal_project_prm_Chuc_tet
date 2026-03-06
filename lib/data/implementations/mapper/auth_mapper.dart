import 'package:personal_project_prm/data/dto/login/login_response_dto.dart';
import 'package:personal_project_prm/data/interfaces/mapper/imapper.dart';
import 'package:personal_project_prm/domain/entities/auth_session.dart';
import 'package:personal_project_prm/domain/entities/user.dart';

class AuthSessionMapper implements IMapper<LoginResponseDto, AuthSession>{
  @override
  AuthSession map(LoginResponseDto input){
    return AuthSession(
        token: input.token,
        user: User(
          id: input.user.id,
          userName: input.user.userName,
          phone: input.user.phone,
          fullName: input.user.fullName,
          avatar: input.user.avatar,
        )
    );
  }
}