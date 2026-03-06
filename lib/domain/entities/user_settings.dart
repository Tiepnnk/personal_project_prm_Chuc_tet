
class UserSettings {
  final int userId;
  final String? myName;
  final String? defaultTone;
  final bool notifyEnabled;
  final List<String>? notifyHours;

  UserSettings({
    required this.userId,
    this.myName,
    this.defaultTone,
    this.notifyEnabled = true,
    this.notifyHours,
  });

}
