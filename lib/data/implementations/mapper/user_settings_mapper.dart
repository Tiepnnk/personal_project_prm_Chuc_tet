import 'dart:convert';
import 'package:personal_project_prm/data/dto/user_settings_dto.dart';
import 'package:personal_project_prm/data/interfaces/mapper/imapper.dart';
import 'package:personal_project_prm/domain/entities/user_settings.dart';

class UserSettingsMapper implements IMapper<UserSettingsDto, UserSettings> {
  @override
  UserSettings map(UserSettingsDto input) {
    return UserSettings(
      userId: input.userId,
      myName: input.myName,
      defaultTone: input.defaultTone,
      notifyEnabled: input.notifyEnabled == 1,
      notifyHours: input.notifyHours != null
          ? List<String>.from(jsonDecode(input.notifyHours!))
          : null,
    );
  }

  UserSettingsDto mapToDto(UserSettings entity) {
    return UserSettingsDto(
      userId: entity.userId,
      myName: entity.myName,
      defaultTone: entity.defaultTone,
      notifyEnabled: entity.notifyEnabled ? 1 : 0,
      notifyHours: entity.notifyHours != null ? jsonEncode(entity.notifyHours) : null,
    );
  }
}
