import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:personal_project_prm/domain/entities/contact.dart' as app;
import 'package:personal_project_prm/domain/entities/phone_contact.dart';

/// Service đọc danh bạ điện thoại, normalize SĐT, phân loại liên hệ
class PhoneContactService {
  // ─── Normalize Phone ───────────────────────────────────────────────────────

  /// Chuẩn hóa SĐT về dạng 0xxxxxxxxx (10 chữ số, bắt đầu bằng 0)
  /// - +84912345678 → 0912345678
  /// - 84912345678  → 0912345678
  /// - 0912 345 678 → 0912345678
  /// - Nếu không nhận dạng được → trả về raw (đã bỏ khoảng trắng)
  String normalizePhone(String raw) {
    // Bỏ khoảng trắng, gạch ngang, dấu chấm
    String cleaned = raw.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');

    // +84xxxxxxxxx → 0xxxxxxxxx
    if (cleaned.startsWith('+84')) {
      cleaned = '0${cleaned.substring(3)}';
    }
    // 84xxxxxxxxx (11 chữ số bắt đầu bằng 84) → 0xxxxxxxxx
    else if (cleaned.startsWith('84') && cleaned.length == 11) {
      cleaned = '0${cleaned.substring(2)}';
    }

    return cleaned;
  }

  // ─── Read Phone Contacts ──────────────────────────────────────────────────

  /// Xin quyền → đọc danh bạ → trả về list PhoneContact (bỏ qua liên hệ không có SĐT)
  /// Throws [PermissionDeniedException] nếu user từ chối quyền
  Future<List<PhoneContact>> readPhoneContacts() async {
    // Xin quyền (chỉ cần READ, không cần WRITE)
    final hasPermission = await FlutterContacts.requestPermission(readonly: true);
    if (!hasPermission) {
      throw PermissionDeniedException('Quyền truy cập danh bạ bị từ chối');
    }

    // Đọc toàn bộ danh bạ (kèm ảnh đại diện)
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    final List<PhoneContact> results = [];

    for (final contact in contacts) {
      // Bỏ qua nếu không có SĐT
      if (contact.phones.isEmpty) continue;

      final rawPhone = contact.phones.first.number;
      final normalized = normalizePhone(rawPhone);

      // Bỏ qua nếu SĐT rỗng sau khi clean
      if (normalized.isEmpty) continue;

      final displayName = contact.displayName.isNotEmpty
          ? contact.displayName
          : 'Không tên';

      results.add(PhoneContact(
        displayName: displayName,
        phone: normalized,
        rawPhone: rawPhone,
        avatar: null, // Không lưu ảnh tạm (quá nặng cho batch import)
      ));
    }

    return results;
  }

  // ─── Classify Contacts ────────────────────────────────────────────────────

  /// So sánh danh bạ điện thoại với danh sách liên hệ đã có trong DB.
  /// Phân thành 3 nhóm: mới / thay đổi (tên khác) / trùng hoàn toàn.
  ClassifiedContacts classifyContacts(
    List<PhoneContact> phoneContacts,
    List<app.Contact> existingContacts,
  ) {
    // Tạo map phone → Contact từ DB để tra cứu nhanh
    final Map<String, app.Contact> existingMap = {};
    for (final c in existingContacts) {
      final normalizedExisting = normalizePhone(c.phone);
      existingMap[normalizedExisting] = c;
    }

    final List<PhoneContact> newContacts = [];
    final List<PhoneContact> changedContacts = [];
    final List<PhoneContact> duplicateContacts = [];

    for (final pc in phoneContacts) {
      final existing = existingMap[pc.phone];

      if (existing == null) {
        // Không tìm thấy SĐT → liên hệ mới
        newContacts.add(pc);
      } else if (existing.fullName.trim().toLowerCase() !=
          pc.displayName.trim().toLowerCase()) {
        // SĐT trùng nhưng tên khác → có thay đổi
        pc.existingId = existing.id;
        changedContacts.add(pc);
      } else {
        // Trùng hoàn toàn
        pc.existingId = existing.id;
        duplicateContacts.add(pc);
      }
    }

    return ClassifiedContacts(
      newContacts: newContacts,
      changedContacts: changedContacts,
      duplicateContacts: duplicateContacts,
    );
  }
}

/// Exception khi user từ chối quyền truy cập danh bạ
class PermissionDeniedException implements Exception {
  final String message;
  const PermissionDeniedException(this.message);

  @override
  String toString() => message;
}
