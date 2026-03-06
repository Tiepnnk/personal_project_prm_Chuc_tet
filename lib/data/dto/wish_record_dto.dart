
class WishRecordDto {
  final String id;
  final String contactId;
  final int year;
  final String status;
  final String? completedAt;
  final String? customMessage;
  final String? followUpNote;
  final String? templateUsedId;

  WishRecordDto({
    required this.id,
    required this.contactId,
    required this.year,
    required this.status,
    this.completedAt,
    this.customMessage,
    this.followUpNote,
    this.templateUsedId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'year': year,
      'status': status,
      'completedAt': completedAt,
      'customMessage': customMessage,
      'followUpNote': followUpNote,
      'templateUsedId': templateUsedId,
    };
  }

  factory WishRecordDto.fromMap(Map<String, dynamic> map) {
    return WishRecordDto(
      id: map['id'] as String,
      contactId: map['contactId'] as String,
      year: map['year'] as int,
      status: map['status'] as String,
      completedAt: map['completedAt'] as String?,
      customMessage: map['customMessage'] as String?,
      followUpNote: map['followUpNote'] as String?,
      templateUsedId: map['templateUsedId'] as String?,
    );
  }
}
