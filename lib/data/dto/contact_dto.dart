
class ContactDto {
  final String id;
  final int userId;
  final String fullName;
  final String? nickname;
  final String? avatar;
  final String phone;
  final String category;
  final String priority;
  final String? note;
  final int isActive;

  ContactDto({
    required this.id,
    required this.userId,
    required this.fullName,
    this.nickname,
    this.avatar,
    required this.phone,
    required this.category,
    required this.priority,
    this.note,
    this.isActive = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'nickname': nickname,
      'avatar': avatar,
      'phone': phone,
      'category': category,
      'priority': priority,
      'note': note,
      'isActive': isActive,
    };
  }

  factory ContactDto.fromMap(Map<String, dynamic> map) {
    return ContactDto(
      id: map['id'] as String,
      userId: map['userId'] as int,
      fullName: map['fullName'] as String,
      nickname: map['nickname'] as String?,
      avatar: map['avatar'] as String?,
      phone: map['phone'] as String,
      category: map['category'] as String,
      priority: map['priority'] as String,
      note: map['note'] as String?,
      isActive: map['isActive'] as int,
    );
  }
}
