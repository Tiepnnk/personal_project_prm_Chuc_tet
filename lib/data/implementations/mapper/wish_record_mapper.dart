import 'package:personal_project_prm/data/dto/wish_record_dto.dart';
import 'package:personal_project_prm/data/interfaces/mapper/imapper.dart';
import 'package:personal_project_prm/domain/entities/wish_record.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class WishRecordMapper implements IMapper<WishRecordDto, WishRecord> {
  @override
  WishRecord map(WishRecordDto input) {
    return WishRecord(
      id: input.id,
      contactId: input.contactId,
      year: input.year,
      status: WishStatusExtension.fromDbString(input.status),
      completedAt: input.completedAt != null ? DateTime.parse(input.completedAt!) : null,
      customMessage: input.customMessage,
      followUpNote: input.followUpNote,
      templateUsedId: input.templateUsedId,
    );
  }

  WishRecordDto mapToDto(WishRecord entity) {
    return WishRecordDto(
      id: entity.id,
      contactId: entity.contactId,
      year: entity.year,
      status: entity.status.toDbString,
      completedAt: entity.completedAt?.toIso8601String(),
      customMessage: entity.customMessage,
      followUpNote: entity.followUpNote,
      templateUsedId: entity.templateUsedId,
    );
  }
}
