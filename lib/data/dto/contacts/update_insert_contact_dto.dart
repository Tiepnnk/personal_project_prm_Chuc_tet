class UpdateInsertContactDto {
  final int userId;
  final String fullName;
  final String? nickname;
  final String phone;
  final String category;
  final String priority;
  final String? note;
  final String? avatar;
  final int isActive;

  const UpdateInsertContactDto({
    required this.userId,
    required this.fullName,
    this.nickname,
    required this.phone,
    required this.category,
    required this.priority,
    this.note,
    this.avatar,
    this.isActive = 1,
  });

  Map<String, dynamic> toMapForInsert(String id) => {
        'id': id,
        'userId': userId,
        'fullName': fullName,
        'nickname': nickname,
        'phone': phone,
        'category': category,
        'priority': priority,
        'note': note,
        'avatar': avatar,
        'isActive': isActive,
      };

  Map<String, dynamic> toMapForUpdate() => {
        'fullName': fullName,
        'nickname': nickname,
        'phone': phone,
        'category': category,
        'priority': priority,
        'note': note,
        'avatar': avatar,
        'isActive': isActive,
      };
}
