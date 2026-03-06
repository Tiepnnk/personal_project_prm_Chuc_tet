import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class WishRecord {
  final String id;
  final String contactId;
  final int year;
  final WishStatus status;
  final DateTime? completedAt;
  final String? customMessage;
  final String? followUpNote;
  final String? templateUsedId;

  WishRecord({
    required this.id,
    required this.contactId,
    required this.year,
    this.status = WishStatus.pending,
    this.completedAt,
    this.customMessage,
    this.followUpNote,
    this.templateUsedId,
  });

}
