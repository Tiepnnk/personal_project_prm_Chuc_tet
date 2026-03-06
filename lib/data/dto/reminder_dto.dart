class ReminderDto {
  final String id;
  final String? contactId;
  final String? wishRecordId;
  final String remindAt;
  final String type;
  final int isDone;

  ReminderDto({
    required this.id,
    this.contactId,
    this.wishRecordId,
    required this.remindAt,
    required this.type,
    this.isDone = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'wishRecordId': wishRecordId,
      'remindAt': remindAt,
      'type': type,
      'isDone': isDone,
    };
  }

  factory ReminderDto.fromMap(Map<String, dynamic> map) {
    return ReminderDto(
      id: map['id'] as String,
      contactId: map['contactId'] as String?,
      wishRecordId: map['wishRecordId'] as String?,
      remindAt: map['remindAt'] as String,
      type: map['type'] as String,
      isDone: map['isDone'] as int,
    );
  }
}
