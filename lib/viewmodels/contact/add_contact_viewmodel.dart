import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personal_project_prm/data/interfaces/repositories/icontact_repository.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class AddContactViewModel extends ChangeNotifier {
  final IContactRepository _contactRepository;

  AddContactViewModel({required IContactRepository contactRepository})
      : _contactRepository = contactRepository;

  // ─── State ───────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool _isSaved = false;
  String? _errorMessage;

  String? _avatarPath;

  // Edit mode
  bool _isEditMode = false;
  String? _editingContactId;

  // ContactCategory default: family
  ContactCategory _selectedCategory = ContactCategory.family;
  ContactPriority _selectedPriority = ContactPriority.must;

  // Field-level errors
  String? _fullNameError;
  String? _phoneError;
  String? _categoryError;
  String? _priorityError;

  // ─── Getters ─────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isSaved => _isSaved;
  bool get isEditMode => _isEditMode;
  String? get errorMessage => _errorMessage;

  String? get avatarPath => _avatarPath;

  ContactCategory get selectedCategory => _selectedCategory;
  ContactPriority get selectedPriority => _selectedPriority;

  String? get fullNameError => _fullNameError;
  String? get phoneError => _phoneError;
  String? get categoryError => _categoryError;
  String? get priorityError => _priorityError;

  // ─── Category + Priority setters ─────────────────────────────────────────────

  void onCategoryChanged(ContactCategory category) {
    _selectedCategory = category;
    _categoryError = null;
    notifyListeners();
  }

  void onPriorityChanged(ContactPriority priority) {
    _selectedPriority = priority;
    _priorityError = null;
    notifyListeners();
  }

  // ─── Image Picker ─────────────────────────────────────────────────────────────

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      _avatarPath = pickedFile.path;
      notifyListeners();
    }
  }

  // ─── Init For Edit ────────────────────────────────────────────────────────────

  void initForEdit(Contact contact) {
    _isEditMode = true;
    _editingContactId = contact.id;
    _avatarPath = contact.avatar;
    _selectedCategory = contact.category;
    _selectedPriority = contact.priority;
    // Clear errors
    _fullNameError = null;
    _phoneError = null;
    _categoryError = null;
    _priorityError = null;
    _isSaved = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Validate ────────────────────────────────────────────────────────────────

  bool _validate(String fullName, String phone) {
    bool isValid = true;

    // fullName
    if (fullName.trim().isEmpty) {
      _fullNameError = 'Họ và tên không được để trống';
      isValid = false;
    } else {
      _fullNameError = null;
    }

    // phone: đúng 10 chữ số, bắt đầu bằng 0, chỉ chứa số
    final phoneRegex = RegExp(r'^0\d{9}$');
    if (phone.trim().isEmpty) {
      _phoneError = 'Số điện thoại không được để trống';
      isValid = false;
    } else if (!phoneRegex.hasMatch(phone.trim())) {
      _phoneError = 'Số điện thoại phải đúng 10 chữ số và bắt đầu bằng 0';
      isValid = false;
    } else {
      _phoneError = null;
    }

    return isValid;
  }

  // ─── Save Contact (Add Mode) ──────────────────────────────────────────────────

  Future<void> saveContact({
    required String fullName,
    required String? nickname,
    required String phone,
    required String? note,
  }) async {
    _errorMessage = null;

    final isValid = _validate(fullName.trim(), phone.trim());
    notifyListeners();

    if (!isValid) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _contactRepository.create(
        fullName.trim(),
        nickname?.trim().isEmpty == true ? null : nickname?.trim(),
        phone.trim(),
        _selectedCategory.toDbString,
        _selectedPriority.toDbString,
        note?.trim().isEmpty == true ? null : note?.trim(),
        _avatarPath,
        1,
      );

      _isSaved = true;
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra khi lưu liên hệ: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Update Contact (Edit Mode) ───────────────────────────────────────────────

  Future<void> updateContact({
    required String fullName,
    required String? nickname,
    required String phone,
    required String? note,
  }) async {
    _errorMessage = null;

    final isValid = _validate(fullName.trim(), phone.trim());
    notifyListeners();

    if (!isValid) return;
    if (_editingContactId == null) {
      _errorMessage = 'Không tìm thấy liên hệ cần cập nhật';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _contactRepository.update(
        _editingContactId!,
        fullName.trim(),
        nickname?.trim().isEmpty == true ? null : nickname?.trim(),
        phone.trim(),
        _selectedCategory.toDbString,
        _selectedPriority.toDbString,
        note?.trim().isEmpty == true ? null : note?.trim(),
        _avatarPath,
        1,
      );

      _isSaved = true;
    } catch (e) {
      _errorMessage = 'Có lỗi xảy ra khi cập nhật liên hệ: ${e.toString()}';
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
    _avatarPath = null;
    _isEditMode = false;
    _editingContactId = null;
    _selectedCategory = ContactCategory.family;
    _selectedPriority = ContactPriority.must;
    _fullNameError = null;
    _phoneError = null;
    _categoryError = null;
    _priorityError = null;
    notifyListeners();
  }
}
