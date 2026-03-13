/// Liên hệ đọc từ danh bạ điện thoại, chưa lưu vào DB
class PhoneContact {
  final String displayName;
  final String phone;       // Đã normalize
  final String rawPhone;    // SĐT gốc (chưa normalize)
  final String? avatar;     // đường dẫn ảnh nếu có

  // User sẽ gán trên UI
  String? nickname;
  String? relationship;     // DB key: "FAMILY", "FRIEND", "BOSS"...
  String? contactLevel;     // "MUST" | "SHOULD" | "OPTIONAL"

  // Nếu SĐT đã tồn tại trong DB
  String? existingId;

  PhoneContact({
    required this.displayName,
    required this.phone,
    required this.rawPhone,
    this.avatar,
    this.nickname,
    this.relationship,
    this.contactLevel,
    this.existingId,
  });

  /// Đã gán đủ cả relationship lẫn contactLevel?
  bool get isFullyAssigned =>
      relationship != null &&
      relationship!.isNotEmpty &&
      contactLevel != null &&
      contactLevel!.isNotEmpty;
}

/// Kết quả phân loại danh bạ sau khi so sánh với DB
class ClassifiedContacts {
  final List<PhoneContact> newContacts;
  final List<PhoneContact> changedContacts;
  final List<PhoneContact> duplicateContacts;

  const ClassifiedContacts({
    required this.newContacts,
    required this.changedContacts,
    required this.duplicateContacts,
  });

  bool get isEmpty =>
      newContacts.isEmpty && changedContacts.isEmpty && duplicateContacts.isEmpty;

  bool get allDuplicates =>
      newContacts.isEmpty && changedContacts.isEmpty && duplicateContacts.isNotEmpty;
}
