import 'package:flutter/material.dart';
import 'package:personal_project_prm/data/implementations/api/openai_service.dart';
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
  final OpenAiService _openAiService;

  WishViewModel({
    required IContactRepository contactRepository,
    required IWishTemplateRepository wishTemplateRepository,
    required IWishRecordRepository wishRecordRepository,
    required OpenAiService openAiService,
  })  : _contactRepository = contactRepository,
        _wishTemplateRepository = wishTemplateRepository,
        _wishRecordRepository = wishRecordRepository,
        _openAiService = openAiService,
        contentController = TextEditingController();

  // ─── State ───────────────────────────────────────────────────────────────

  final TextEditingController contentController;

  Contact? _selectedContact;
  List<Contact> _selectedContacts = [];
  List<Contact> _contactsToConfirm = [];
  WishTemplate? _selectedTemplate;
  WishRecord? _activeRecord;

  // Contacts tab state
  List<Contact> _allPendingContacts = [];
  String _contactSearchQuery = '';
  String _contactPriorityFilter = 'Tất cả'; // 'Tất cả' | 'MUST' | 'SHOULD' | 'OPTION'
  ContactCategory? _activeCategory; // Mối quan hệ đang được khoá khi chọn người đầu tiên

  // Templates tab state
  List<WishTemplate> _allTemplates = [];
  String _templateSearchQuery = '';

  bool _isLoadingContacts = false;
  bool _isLoadingTemplates = false;
  String? _errorMessage;

  // AI suggestion state
  bool _isGeneratingAi = false;
  String? _aiError;

  // ─── Getters ─────────────────────────────────────────────────────────────

  Contact? get selectedContact => _selectedContact;
  List<Contact> get selectedContacts => _selectedContacts;
  bool get isMultiSelect => _selectedContacts.length >= 2;
  String? get bulkRelationship => _selectedContacts.isNotEmpty ? _selectedContacts.first.category.displayName : null;
  List<Contact> get contactsToConfirm => _contactsToConfirm;
  WishTemplate? get selectedTemplate => _selectedTemplate;
  WishRecord? get activeRecord => _activeRecord;
  bool get isLoadingContacts => _isLoadingContacts;
  bool get isLoadingTemplates => _isLoadingTemplates;
  String? get errorMessage => _errorMessage;
  String get contactPriorityFilter => _contactPriorityFilter;
  ContactCategory? get activeCategory => _activeCategory;
  bool get isGeneratingAi => _isGeneratingAi;
  String? get aiError => _aiError;
  String get contactSearchQuery => _contactSearchQuery;
  String get templateSearchQuery => _templateSearchQuery;

  List<Contact> get displayedContacts {
    var result = _allPendingContacts;

    // Filter theo mối quan hệ khi đã có lựa chọn đầu tiên
    if (_activeCategory != null) {
      result = result.where((c) => c.category == _activeCategory).toList();
    }

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
    // Toggle: nếu đã chọn contact này rồi → bỏ chọn (trong chế độ single sẽ là contact duy nhất)
    if (_selectedContacts.any((c) => c.id == contact.id)) {
      _selectedContacts.removeWhere((c) => c.id == contact.id);
      if (_selectedContacts.isEmpty) {
        _selectedContact = null;
        _selectedTemplate = null;
        _activeCategory = null; // Reset khoá mối quan hệ
        contentController.clear();
      } else {
        _selectedContact = _selectedContacts.first;
      }
      _activeRecord = null;
      notifyListeners();
      return;
    }
    _selectedContact = contact;
    _selectedContacts = [contact];
    _activeCategory = contact.category; // Khoá danh sách theo mối quan hệ đầu tiên
    // Reset template và content khi đổi contact
    _selectedTemplate = null;
    contentController.clear();
    _activeRecord = null;
    notifyListeners();
  }

  void toggleBulkContact(Contact contact) {
    if (_selectedContacts.isEmpty) {
      _selectedContacts.add(contact);
      _selectedContact = contact;
      _activeCategory = contact.category; // Khoá danh sách theo mối quan hệ đầu tiên
    } else {
      if (_selectedContacts.any((c) => c.id == contact.id)) {
        _selectedContacts.removeWhere((c) => c.id == contact.id);
        if (_selectedContacts.isEmpty) {
          _selectedContact = null;
          _selectedTemplate = null;
          _activeCategory = null; // Reset khoá mối quan hệ
          contentController.clear();
        } else {
          _selectedContact = _selectedContacts.first;
        }
      } else {
        if (contact.category != _activeCategory) {
          return; // Không thuộc cùng mối quan hệ → bỏ qua
        }
        _selectedContacts.add(contact);
      }
    }
    _activeRecord = null;
    notifyListeners();
  }

  /// Xóa lựa chọn contact hiện tại
  void deselectContact() {
    _selectedContact = null;
    _selectedContacts.clear();
    _selectedTemplate = null;
    _activeCategory = null; // Reset khoá mối quan hệ
    contentController.clear();
    _activeRecord = null;
    notifyListeners();
  }

  void clearBulkContacts() => deselectContact();

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

  // ─── AI Suggestion ──────────────────────────────────────────────────────

  /// Gọi OpenAI để gợi ý nội dung lời chúc dựa trên contact và template (nếu có)
  Future<void> generateAiWishContent() async {
    if (_selectedContacts.isEmpty) return;

    _isGeneratingAi = true;
    _aiError = null;
    notifyListeners();

    try {
      String result;
      if (isMultiSelect) {
        result = await _openAiService.generateGroupWishContent(
          relationship: bulkRelationship!,
          memberCount: _selectedContacts.length,
          templateContent: _selectedTemplate?.content,
        );
      } else {
        result = await _openAiService.generateWishContent(
          contactName: _selectedContact!.fullName,
          relationship: _selectedContact!.category.displayName,
          templateContent: _selectedTemplate?.content,
        );
      }
      contentController.text = result;
    } catch (e) {
      _aiError = 'Không thể tạo gợi ý: ${e.toString()}';
    } finally {
      _isGeneratingAi = false;
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
    _selectedContacts.clear();
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
    if (_selectedContacts.isEmpty) return false;
    final phones = _selectedContacts.map((c) => c.phone.replaceAll(' ', '')).join(',');
    final body = Uri.encodeComponent(contentController.text.trim());
    final uri = Uri.parse('sms:$phones?body=$body');
    if (!await canLaunchUrl(uri)) return false;
    await launchUrl(uri);
    return true;
  }
  
  void initConfirmStates() {
    _contactsToConfirm = List.from(_selectedContacts);
    notifyListeners();
  }

  Future<void> markContactAsMessaged(Contact contact) async {
    final year = DateTime.now().year;
    final record = await _wishRecordRepository.getOrCreate(
      contact.id,
      year,
    );

    await _wishRecordRepository.updateStatus(
      record.id,
      WishStatus.messaged,
      completedAt: DateTime.now(),
      customMessage: contentController.text.trim().isNotEmpty
          ? contentController.text.trim()
          : null,
      templateUsedId: _selectedTemplate?.id,
    );

    _allPendingContacts.removeWhere((c) => c.id == contact.id);
    _contactsToConfirm.removeWhere((c) => c.id == contact.id);
    notifyListeners();
  }

  void skipContact(Contact contact) {
    _contactsToConfirm.removeWhere((c) => c.id == contact.id);
    notifyListeners();
  }

  void completeConfirmFlow() {
    if (_selectedTemplate != null) {
      _wishTemplateRepository.incrementUsage(_selectedTemplate!.id);
    }
    _selectedContacts.clear();
    _selectedContact = null;
    _selectedTemplate = null;
    contentController.clear();
    _activeRecord = null;
    _contactsToConfirm.clear();
    notifyListeners();
  }

  // ─── Cleanup ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }
}
