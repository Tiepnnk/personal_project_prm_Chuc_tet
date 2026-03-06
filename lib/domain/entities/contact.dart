import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class Contact {
  final String id;
  final String fullName;
  final String? nickname;
  final String? avatar;
  final String phone;
  final ContactCategory category;
  final ContactPriority priority;
  final String? note;
  final bool isActive;
  final int userId;

  Contact({
    required this.id,
    required this.userId,
    required this.fullName,
    this.nickname,
    this.avatar,
    required this.phone,
    required this.category,
    required this.priority,
    this.note,
    this.isActive = true,
  });

}
