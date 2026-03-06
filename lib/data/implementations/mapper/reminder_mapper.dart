import 'package:personal_project_prm/data/dto/reminder_dto.dart';
import 'package:personal_project_prm/data/interfaces/mapper/imapper.dart';
import 'package:personal_project_prm/domain/entities/reminder.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class ReminderMapper implements IMapper<ReminderDto, Reminder> {
  @override
  Reminder map(ReminderDto input) {
    return Reminder(
      id: input.id,
      contactId: input.contactId,
      wishRecordId: input.wishRecordId,
      remindAt: DateTime.parse(input.remindAt),
      type: ReminderTypeExtension.fromDbString(input.type),
      isDone: input.isDone == 1,
    );
  }

  ReminderDto mapToDto(Reminder entity) {
    return ReminderDto(
      id: entity.id,
      contactId: entity.contactId,
      wishRecordId: entity.wishRecordId,
      remindAt: entity.remindAt.toIso8601String(),
      type: entity.type.toDbString,
      isDone: entity.isDone ? 1 : 0,
    );
  }
}
