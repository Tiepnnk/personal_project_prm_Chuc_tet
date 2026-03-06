enum ContactCategory {
  family,
  boss,
  colleague,
  partner,
  friend,
  teacher,
  neighbor,
  other
}

enum ContactPriority {
  must,
  should,
  optional
}

enum WishStatus {
  pending,
  called,
  calledBack
}

enum ReminderType {
  remindCallBack,
  remindDate
}

// Extensions for easy SQLite mapping (string <-> enum)
extension ContactCategoryExtension on ContactCategory {
  String get toDbString => name.toUpperCase();
  
  String get displayName {
    switch (this) {
      case ContactCategory.family:
        return 'Gia đình';
      case ContactCategory.boss:
        return 'Sếp';
      case ContactCategory.colleague:
        return 'Đồng nghiệp';
      case ContactCategory.partner:
        return 'Đối tác';
      case ContactCategory.friend:
        return 'Bạn bè';
      case ContactCategory.teacher:
        return 'Thầy cô';
      case ContactCategory.neighbor:
        return 'Hàng xóm';
      case ContactCategory.other:
        return 'Khác';
    }
  }

  static ContactCategory fromDbString(String str) {
    return ContactCategory.values.firstWhere(
      (e) => e.name.toUpperCase() == str.toUpperCase(),
      orElse: () => ContactCategory.other,
    );
  }
}

extension ContactPriorityExtension on ContactPriority {
  String get toDbString => name.toUpperCase();

  String get displayName {
    switch (this) {
      case ContactPriority.must:
        return 'Bắt buộc';
      case ContactPriority.should:
        return 'Nên gọi';
      case ContactPriority.optional:
        return 'Tùy chọn';
    }
  }

  static ContactPriority fromDbString(String str) {
    return ContactPriority.values.firstWhere(
      (e) => e.name.toUpperCase() == str.toUpperCase(),
      orElse: () => ContactPriority.optional,
    );
  }
}

extension WishStatusExtension on WishStatus {
  String get toDbString {
    if (this == WishStatus.calledBack) return 'CALLED_BACK';
    return name.toUpperCase();
  }
  static WishStatus fromDbString(String str) {
    if (str.toUpperCase() == 'CALLED_BACK') return WishStatus.calledBack;
    return WishStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == str.toUpperCase(),
      orElse: () => WishStatus.pending,
    );
  }
}

extension ReminderTypeExtension on ReminderType {
  String get toDbString {
    if (this == ReminderType.remindCallBack) return 'REMIND_CALL_BACK';
    if (this == ReminderType.remindDate) return 'REMIND_DATE';
    return name.toUpperCase();
  }
  static ReminderType fromDbString(String str) {
    if (str.toUpperCase() == 'REMIND_CALL_BACK') return ReminderType.remindCallBack;
    if (str.toUpperCase() == 'REMIND_DATE') return ReminderType.remindDate;
    return ReminderType.remindDate;
  }
}
