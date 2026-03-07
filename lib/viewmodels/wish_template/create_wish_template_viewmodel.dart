import 'package:flutter/material.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iwish_template_repository.dart';
import 'package:personal_project_prm/domain/entities/wish_template.dart';

// Các nhóm có thể chọn khi tạo/sửa template (phải khớp với UI)
const List<String> availableGroups = [
  'Gia đình',
  'Sếp',
  'Đồng nghiệp',
  'Đối tác',
  'Bạn bè',
  'Thầy cô',
  'Hàng xóm',
  'Khác',
];

// Map từ display name → DB key
const _groupToDbKey = {
  'Gia đình': 'FAMILY',
  'Sếp': 'BOSS',
  'Đồng nghiệp': 'COLLEAGUE',
  'Đối tác': 'PARTNER',
  'Bạn bè': 'FRIEND',
  'Thầy cô': 'TEACHER',
  'Hàng xóm': 'NEIGHBOR',
  'Khác': 'OTHER',
};

class CreateWishTemplateViewModel extends ChangeNotifier {
  final IWishTemplateRepository _repository;

  CreateWishTemplateViewModel({required IWishTemplateRepository repository})
      : _repository = repository;

  // ─── State ───────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool _isSaved = false;
  String? _errorMessage;

  // Edit mode
  bool _isEditMode = false;
  String? _editingTemplateId;

  // Form state
  Set<String> _selectedGroups = {'Gia đình'};
  bool _isFavorite = false;

  // Field errors
  String? _titleError;
  String? _contentError;

  // ─── Getters ─────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isSaved => _isSaved;
  bool get isEditMode => _isEditMode;
  String? get errorMessage => _errorMessage;
  Set<String> get selectedGroups => _selectedGroups;
  bool get isFavorite => _isFavorite;
  String? get titleError => _titleError;
  String? get contentError => _contentError;

  // ─── Group & Favorite setters ─────────────────────────────────────────────────

  void onGroupToggled(String group) {
    if (_selectedGroups.contains(group)) {
      _selectedGroups = Set.from(_selectedGroups)..remove(group);
    } else {
      _selectedGroups = Set.from(_selectedGroups)..add(group);
    }
    notifyListeners();
  }

  void onFavoriteToggled(bool value) {
    _isFavorite = value;
    notifyListeners();
  }

  // ─── Init For Edit ────────────────────────────────────────────────────────────

  void initForEdit(WishTemplate template) {
    _isEditMode = true;
    _editingTemplateId = template.id;
    _isFavorite = template.isFavorite;

    // Convert DB keys back to display names
    final displayGroups = template.targetGroups.map((dbKey) {
      return _groupToDbKey.entries
          .firstWhere(
            (e) => e.value == dbKey.toUpperCase(),
            orElse: () => MapEntry(dbKey, dbKey),
          )
          .key;
    }).toSet();
    _selectedGroups = displayGroups.isEmpty ? {'Gia đình'} : displayGroups;

    // Clear errors
    _titleError = null;
    _contentError = null;
    _isSaved = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Validate ────────────────────────────────────────────────────────────────

  bool _validate(String title, String content) {
    bool isValid = true;

    if (title.trim().isEmpty) {
      _titleError = 'Tiêu đề không được để trống';
      isValid = false;
    } else {
      _titleError = null;
    }

    if (content.trim().isEmpty) {
      _contentError = 'Nội dung không được để trống';
      isValid = false;
    } else {
      _contentError = null;
    }

    return isValid;
  }

  // ─── Save Template ────────────────────────────────────────────────────────────

  Future<void> saveTemplate({
    required String title,
    required String content,
  }) async {
    _errorMessage = null;

    final isValid = _validate(title.trim(), content.trim());
    notifyListeners();

    if (!isValid) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Convert display names → DB keys
      final dbGroups = _selectedGroups.map((displayName) {
        return _groupToDbKey[displayName] ?? displayName.toUpperCase();
      }).toList();

      if (_isEditMode && _editingTemplateId != null) {
        await _repository.update(
          _editingTemplateId!,
          title.trim(),
          content.trim(),
          dbGroups,
          _isFavorite,
        );
      } else {
        await _repository.create(
          title.trim(),
          content.trim(),
          dbGroups,
          _isFavorite,
        );
      }

      _isSaved = true;
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra khi lưu mẫu: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Reset ────────────────────────────────────────────────────────────────────

  void reset() {
    _isLoading = false;
    _isSaved = false;
    _errorMessage = null;
    _isEditMode = false;
    _editingTemplateId = null;
    _selectedGroups = {'Gia đình'};
    _isFavorite = false;
    _titleError = null;
    _contentError = null;
    notifyListeners();
  }
}
