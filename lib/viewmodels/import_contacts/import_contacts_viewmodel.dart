import 'package:flutter/material.dart';
import 'package:personal_project_prm/data/implementations/api/phone_contact_service.dart';
import 'package:personal_project_prm/data/interfaces/repositories/icontact_repository.dart';
import 'package:personal_project_prm/domain/entities/phone_contact.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';

/// ViewModel cho trang Import Contacts, quản lý toàn bộ luồng import
class ImportContactsViewModel extends ChangeNotifier {
  final PhoneContactService _phoneContactService;
  final IContactRepository _contactRepository;

  ImportContactsViewModel({
    required PhoneContactService phoneContactService,
    required IContactRepository contactRepository,
  })  : _phoneContactService = phoneContactService,
        _contactRepository = contactRepository;

  // ─── State ───────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool _isImporting = false;
  bool _permissionDenied = false;
  String? _errorMessage;

  ClassifiedContacts? _classified;

  // Lưu trạng thái checkbox cho nhóm "thay đổi"
  List<bool> _changedSelection = [];

  // ─── Getters ─────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isImporting => _isImporting;
  bool get permissionDenied => _permissionDenied;
  String? get errorMessage => _errorMessage;

  ClassifiedContacts? get classified => _classified;
  List<PhoneContact> get newContacts => _classified?.newContacts ?? [];
  List<PhoneContact> get changedContacts => _classified?.changedContacts ?? [];
  List<PhoneContact> get duplicateContacts => _classified?.duplicateContacts ?? [];
  List<bool> get changedSelection => _changedSelection;

  /// Tổng liên hệ mới đã gán đủ thông tin (sẽ thực sự được import)
  int get assignedCount =>
      newContacts.where((c) => c.isFullyAssigned).length;

  /// Tổng liên hệ sẽ import (mới đã gán đủ + thay đổi được chọn)
  int get totalImportCount {
    final changedCount = _changedSelection.where((s) => s).length;
    return assignedCount + changedCount;
  }

  /// Trạng thái: tất cả đều trùng
  bool get allDuplicates => _classified?.allDuplicates ?? false;

  /// Trạng thái: danh bạ trống
  bool get isEmpty => _classified?.isEmpty ?? false;

  // ─── Load Phone Contacts ─────────────────────────────────────────────────────

  Future<void> loadPhoneContacts() async {
    _isLoading = true;
    _errorMessage = null;
    _permissionDenied = false;
    notifyListeners();

    try {
      // 1. Đọc danh bạ điện thoại
      final phoneContacts = await _phoneContactService.readPhoneContacts();

      // 2. Lấy danh sách liên hệ đã có trong DB
      final existingContacts = await _contactRepository.getAll();

      // 3. Phân loại
      _classified = _phoneContactService.classifyContacts(
        phoneContacts,
        existingContacts,
      );

      // Khởi tạo selection cho nhóm thay đổi (mặc định: chọn hết)
      _changedSelection = List.filled(changedContacts.length, true);
    } on PermissionDeniedException {
      _permissionDenied = true;
    } catch (e) {
      _errorMessage = 'Không thể đọc danh bạ: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Update UI Fields ────────────────────────────────────────────────────────

  void updateRelationship(int index, String? value) {
    if (index < newContacts.length) {
      newContacts[index].relationship = value;
      notifyListeners();
    }
  }

  void updateContactLevel(int index, String? value) {
    if (index < newContacts.length) {
      newContacts[index].contactLevel = value;
      notifyListeners();
    }
  }

  void updateNickname(int index, String value) {
    if (index < newContacts.length) {
      newContacts[index].nickname = value.isEmpty ? null : value;
      // Không gọi notifyListeners() ở đây để tránh rebuild khi gõ
    }
  }

  void removeNewContact(int index) {
    if (index >= 0 && index < newContacts.length) {
      newContacts.removeAt(index);
      notifyListeners();
    }
  }

  void toggleChangedSelection(int index) {
    if (index < _changedSelection.length) {
      _changedSelection[index] = !_changedSelection[index];
      notifyListeners();
    }
  }

  // ─── Import Contacts ─────────────────────────────────────────────────────────

  /// INSERT nhóm mới, UPDATE nhóm thay đổi (chỉ name/avatar), bỏ qua trùng
  Future<bool> importContacts() async {
    _isImporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. INSERT nhóm mới — chỉ import những contact đã gán đủ mối quan hệ & mức độ
      for (final pc in newContacts) {
        if (!pc.isFullyAssigned) continue; // Chưa chọn đủ → bỏ qua
        await _contactRepository.create(
          pc.displayName,
          pc.nickname,
          pc.phone,
          pc.relationship!,
          pc.contactLevel!,
          null, // note
          pc.avatar,
          1, // isActive
        );
      }

      // 2. UPDATE nhóm thay đổi (chỉ ghi đè name/avatar, giữ nguyên fields khác)
      for (int i = 0; i < changedContacts.length; i++) {
        if (!_changedSelection[i]) continue; // User bỏ chọn → skip

        final pc = changedContacts[i];
        if (pc.existingId == null) continue;

        // Lấy thông tin hiện tại từ DB để giữ nguyên nickname, category, priority
        final existing = await _contactRepository.getById(pc.existingId!);
        if (existing == null) continue;

        await _contactRepository.update(
          pc.existingId!,
          pc.displayName,              // Ghi đè tên mới
          existing.nickname,           // Giữ nguyên nickname
          pc.phone,
          existing.category.toDbString, // Giữ nguyên category
          existing.priority.toDbString, // Giữ nguyên priority
          existing.note,                // Giữ nguyên note
          pc.avatar ?? existing.avatar, // Ghi đè avatar nếu có, không thì giữ
          1,
        );
      }

      // 3. Nhóm trùng hoàn toàn → bỏ qua, không làm gì

      return true; // Thành công
    } catch (e) {
      _errorMessage = 'Lỗi khi import: ${e.toString()}';
      return false;
    } finally {
      _isImporting = false;
      notifyListeners();

      // Tải lại & phân loại lại danh bạ sau khi import thành công
      // → contacts vừa import sẽ được nhận diện là trùng và không hiện lại
      // → tránh người dùng vô tình import lại gây duplicate
      await loadPhoneContacts();
    }
  }
}
