class UserSettingsDto {
  final int userId;
  final String? myName;
  final String? defaultTone;
  final int notifyEnabled;
  final String? notifyHours;

  UserSettingsDto({
    required this.userId,
    this.myName,
    this.defaultTone,
    this.notifyEnabled = 1,
    this.notifyHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'myName': myName,
      'defaultTone': defaultTone,
      'notifyEnabled': notifyEnabled,
      'notifyHours': notifyHours,
    };
  }

  factory UserSettingsDto.fromMap(Map<String, dynamic> map) {
    return UserSettingsDto(
      userId: map['userId'] as int,
      myName: map['myName'] as String?,
      defaultTone: map['defaultTone'] as String?,
      notifyEnabled: map['notifyEnabled'] as int,
      notifyHours: map['notifyHours'] as String?,
    );
  }
}
