import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class Reminder {
  final String id;
  final String? contactId;
  final String? wishRecordId;
  final DateTime remindAt;
  final ReminderType type;
  final bool isDone;

  Reminder({
    required this.id,
    this.contactId,
    this.wishRecordId,
    required this.remindAt,
    required this.type,
    this.isDone = false,
  });

}
