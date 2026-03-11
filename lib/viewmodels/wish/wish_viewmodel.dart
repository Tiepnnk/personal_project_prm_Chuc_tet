import 'package:flutter/material.dart';
import 'package:personal_project_prm/data/interfaces/repositories/icontact_repository.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iwish_record_repository.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iwish_template_repository.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';
import 'package:personal_project_prm/domain/entities/wish_record.dart';
import 'package:personal_project_prm/domain/entities/wish_template.dart';
import 'package:url_launcher/url_launcher.dart';

class WishViewModel extends ChangeNotifier {
  final IContactRepository _contactRepository;
  final IWishTemplateRepository _wishTemplateRepository;
  final IWishRecordRepository _wishRecordRepository;

  WishViewModel({
    required IContactRepository contactRepository,
    required IWishTemplateRepository wishTemplateRepository,
    required IWishRecordRepository wishRecordRepository,
  })  : _contactRepository = contactRepository,
        _wishTemplateRepository = wishTemplateRepository,
        _wishRecordRepository = wishRecordRepository,
        contentController = TextEditingController();

  // ─── State ───────────────────────────────────────────────────────────────

  final TextEditingController contentController;

  Contact? _selectedContact;
  WishTemplate? _selectedTemplate;
  WishRecord? _activeRecord;

  // Contacts tab state
  List<Contact> _allPendingContacts = [];
  String _contactSearchQuery = '';
  String _contactPriorityFilter = 'Tất cả'; // 'Tất cả' | 'MUST' | 'SHOULD' | 'OPTION'

  // Templates tab state
  List<WishTemplate> _allTemplates = [];
  String _templateSearchQuery = '';

  bool _isLoadingContacts = false;
  bool _isLoadingTemplates = false;
  String? _errorMessage;

  // ─── Getters ─────────────────────────────────────────────────────────────

  Contact? get selectedContact => _selectedContact;
  WishTemplate? get selectedTemplate => _selectedTemplate;
  WishRecord? get activeRecord => _activeRecord;
  bool get isLoadingContacts => _isLoadingContacts;
  bool get isLoadingTemplates => _isLoadingTemplates;
  String? get errorMessage => _errorMessage;
  String get contactPriorityFilter => _contactPriorityFilter;
  String get contactSearchQuery => _contactSearchQuery;
  String get templateSearchQuery => _templateSearchQuery;

  List<Contact> get displayedContacts {
    var result = _allPendingContacts;

    // Filter theo priority chip
    if (_contactPriorityFilter != 'Tất cả') {
      result = result.where((c) {
        switch (_contactPriorityFilter) {
          case 'Bắt buộc':
            return c.priority == ContactPriority.must;
          case 'Nên gọi':
            return c.priority == ContactPriority.should;
          case 'Tùy chọn':
            return c.priority == ContactPriority.optional;
          default:
            return true;
        }
      }).toList();
    }

    // Filter theo search query (tên, biệt danh, SĐT)
    if (_contactSearchQuery.trim().isNotEmpty) {
      final q = _contactSearchQuery.trim().toLowerCase();
      final qPhone = q.replaceAll(' ', '');
      result = result.where((c) {
        final phoneClean = c.phone.replaceAll(' ', '').toLowerCase();
        return c.fullName.toLowerCase().contains(q) ||
            (c.nickname?.toLowerCase().contains(q) ?? false) ||
            phoneClean.contains(qPhone);
      }).toList();
    }

    return result;
  }

  List<WishTemplate> get displayedTemplates {
    var result = _allTemplates;

    // Filter theo mối quan hệ của contact đã chọn
    if (_selectedContact != null) {
      final dbKey = _selectedContact!.category.toDbString;
      result = result.where((t) {
        return t.targetGroups.any((g) => g.toUpperCase() == dbKey);
      }).toList();
    }

    // Filter theo search
    if (_templateSearchQuery.trim().isNotEmpty) {
      final q = _templateSearchQuery.trim().toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(q)).toList();
    }

    return result;
  }

  // ─── Contact Actions ─────────────────────────────────────────────────────

  Future<void> loadPendingContacts() async {
    _isLoadingContacts = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final year = DateTime.now().year;
      // Lấy toàn bộ contact của user
      final allContacts = await _contactRepository.getAll();

      // Lấy danh sách contactId đã có wish_record PENDING
      final pendingIds = await _wishRecordRepository.getPendingContactIds(year);

      // Các contact chưa có wish_record nào cũng cần hiển thị (mặc định PENDING)
      // → lọc những contact KHÔNG có record hoặc có record PENDING
      final recordedIds = await _getRecordedContactIds(year);

      _allPendingContacts = allContacts.where((c) {
        if (!recordedIds.contains(c.id)) return true; // chưa có record → hiển thị
        return pendingIds.contains(c.id); // có record PENDING → hiển thị
      }).toList();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách liên lạc: ${e.toString()}';
    } finally {
      _isLoadingContacts = false;
      notifyListeners();
    }
  }

  Future<List<String>> _getRecordedContactIds(int year) async {
    return _wishRecordRepository.getAllRecordedContactIds(year);
  }

  void selectContact(Contact contact) {
    // Toggle: nếu đã chọn contact này rồi → bỏ chọn
    if (_selectedContact?.id == contact.id) {
      _selectedContact = null;
      _selectedTemplate = null;
      contentController.clear();
      _activeRecord = null;
      notifyListeners();
      return;
    }
    _selectedContact = contact;
    // Reset template và content khi đổi contact
    _selectedTemplate = null;
    contentController.clear();
    _activeRecord = null;
    notifyListeners();
  }

  /// Xóa lựa chọn contact hiện tại
  void deselectContact() {
    _selectedContact = null;
    _selectedTemplate = null;
    contentController.clear();
    _activeRecord = null;
    notifyListeners();
  }

  void setContactFilter(String priority) {
    _contactPriorityFilter = priority;
    notifyListeners();
  }

  void setContactSearch(String query) {
    _contactSearchQuery = query;
    notifyListeners();
  }

  // ─── Template Actions ────────────────────────────────────────────────────

  Future<void> loadTemplates() async {
    _isLoadingTemplates = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTemplates = await _wishTemplateRepository.getAll();
    } catch (e) {
      _errorMessage = 'Không thể tải mẫu lời chúc: ${e.toString()}';
    } finally {
      _isLoadingTemplates = false;
      notifyListeners();
    }
  }

  void selectTemplate(WishTemplate template) {
    // Toggle: nếu đã chọn template này rồi → bỏ chọn
    if (_selectedTemplate?.id == template.id) {
      _selectedTemplate = null;
      contentController.clear();
      notifyListeners();
      return;
    }
    _selectedTemplate = template;
    contentController.text = template.content;
    notifyListeners();
  }

  /// Xóa lựa chọn template hiện tại
  void deselectTemplate() {
    _selectedTemplate = null;
    contentController.clear();
    notifyListeners();
  }

  void setTemplateSearch(String query) {
    _templateSearchQuery = query;
    notifyListeners();
  }

  Future<void> toggleFavoriteTemplate(String id, bool currentValue) async {
    try {
      await _wishTemplateRepository.toggleFavorite(id, !currentValue);
      final idx = _allTemplates.indexWhere((t) => t.id == id);
      if (idx != -1) {
        final old = _allTemplates[idx];
        _allTemplates[idx] = WishTemplate(
          id: old.id,
          userId: old.userId,
          title: old.title,
          content: old.content,
          targetGroups: old.targetGroups,
          isFavorite: !currentValue,
          usageCount: old.usageCount,
          isSystem: old.isSystem,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Không thể cập nhật yêu thích: ${e.toString()}';
      notifyListeners();
    }
  }

  // ─── Call Action ─────────────────────────────────────────────────────────

  Future<bool> callContact() async {
    if (_selectedContact == null) return false;

    final phone = _selectedContact!.phone.replaceAll(' ', '');
    final uri = Uri(scheme: 'tel', path: phone);

    if (!await canLaunchUrl(uri)) return false;
    await launchUrl(uri);

    // Tạo/lấy wish_record để cập nhật sau
    final year = DateTime.now().year;
    _activeRecord = await _wishRecordRepository.getOrCreate(
      _selectedContact!.id,
      year,
    );
    notifyListeners();
    return true;
  }

  /// Gọi sau khi người dùng xác nhận đã nghe máy
  Future<void> markAsCalled() async {
    if (_activeRecord == null) return;
    await _wishRecordRepository.updateStatus(
      _activeRecord!.id,
      WishStatus.called,
      completedAt: DateTime.now(),
      customMessage: contentController.text.trim().isNotEmpty
          ? contentController.text.trim()
          : null,
      templateUsedId: _selectedTemplate?.id,
    );

    // Tăng usageCount template nếu có
    if (_selectedTemplate != null) {
      await _wishTemplateRepository.incrementUsage(_selectedTemplate!.id);
    }

    // Xóa contact đã gọi khỏi danh sách pending
    if (_selectedContact != null) {
      _allPendingContacts.removeWhere((c) => c.id == _selectedContact!.id);
    }

    // Reset
    _activeRecord = null;
    _selectedContact = null;
    _selectedTemplate = null;
    contentController.clear();
    notifyListeners();
  }

  /// Gọi sau khi người dùng xác nhận chưa nghe máy
  Future<void> markAsNotAnswered() async {
    // Giữ trạng thái PENDING, không làm gì
    _activeRecord = null;
    notifyListeners();
  }

  // ─── Send Action ─────────────────────────────────────────────────────────

  /// Xử lý khi gửi qua SMS native
  Future<bool> sendViaSms() async {
    if (_selectedContact == null) return false;
    final phone = _selectedContact!.phone.replaceAll(' ', '');
    final body = Uri.encodeComponent(contentController.text.trim());
    final uri = Uri.parse('sms:$phone?body=$body');
    if (!await canLaunchUrl(uri)) return false;
    await launchUrl(uri);
    return true;
  }


  /// Gọi sau khi người dùng xác nhận đã gửi thành công
  Future<void> markAsMessaged() async {
    if (_selectedContact == null) return;
    final year = DateTime.now().year;
    _activeRecord ??= await _wishRecordRepository.getOrCreate(
      _selectedContact!.id,
      year,
    );

    await _wishRecordRepository.updateStatus(
      _activeRecord!.id,
      WishStatus.messaged,
      completedAt: DateTime.now(),
      customMessage: contentController.text.trim().isNotEmpty
          ? contentController.text.trim()
          : null,
      templateUsedId: _selectedTemplate?.id,
    );

    if (_selectedTemplate != null) {
      await _wishTemplateRepository.incrementUsage(_selectedTemplate!.id);
    }

    // Xóa contact đã nhắn khỏi danh sách pending
    if (_selectedContact != null) {
      _allPendingContacts.removeWhere((c) => c.id == _selectedContact!.id);
    }

    // Reset
    _activeRecord = null;
    _selectedContact = null;
    _selectedTemplate = null;
    contentController.clear();
    notifyListeners();
  }

  // ─── Cleanup ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }
}
