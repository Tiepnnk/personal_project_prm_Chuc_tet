import 'package:flutter/material.dart';
import 'package:personal_project_prm/data/interfaces/repositories/icontact_repository.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iwish_record_repository.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class ContactViewModel extends ChangeNotifier {
  final IContactRepository _contactRepository;
  final IWishRecordRepository _wishRecordRepository;

  ContactViewModel({
    required IContactRepository contactRepository,
    required IWishRecordRepository wishRecordRepository,
  })  : _contactRepository = contactRepository,
        _wishRecordRepository = wishRecordRepository;

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];

  /// Map contactId → WishStatus (trạng thái chúc Tết năm nay)
  Map<String, WishStatus> _wishStatusMap = {};

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  // State for Selection Mode
  bool _isSelectionMode = false;
  final Set<String> _selectedContactIds = {};

  // Getters
  List<Contact> get filteredContacts => _filteredContacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedContactIds => _selectedContactIds;

  /// Lấy WishStatus của một contact trong năm nay, null nếu chưa có record
  WishStatus? getWishStatus(String contactId) => _wishStatusMap[contactId];

  // Categories based on UI
  final List<String> categories = [
    'Tất cả',
    'Gia đình', // FAMILY
    'Sếp',      // BOSS
    'Đồng nghiệp', // COLLEAGUE
    'Đối tác',  // PARTNER
    'Bạn bè',   // FRIEND
    'Thầy cô',  // TEACHER
    'Hàng xóm', // NEIGHBOR
    'Khác',     // OTHER
  ];

  /// Initialize and load all contacts + wish statuses
  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _contactRepository.seedDemoIfEmpty();
      _allContacts = await _contactRepository.getAll();

      // Tải trạng thái chúc Tết năm hiện tại
      final year = DateTime.now().year;
      _wishStatusMap = await _wishRecordRepository.getStatusMapForYear(year);

      _applyFilters();
    } catch (e) {
      print('Error loading contacts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gọi sau khi WishViewModel cập nhật status (called/messaged) để refresh badge
  Future<void> refreshWishStatuses() async {
    try {
      final year = DateTime.now().year;
      _wishStatusMap = await _wishRecordRepository.getStatusMapForYear(year);
      notifyListeners();
    } catch (_) {}
  }

  /// Update Search Query
  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Update Category Filter
  void onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Delete a contact by id
  Future<void> deleteContact(String id) async {
    try {
      await _contactRepository.delete(id);
      _allContacts.removeWhere((c) => c.id == id);
      _selectedContactIds.remove(id);
      _applyFilters();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Xóa liên hệ thất bại: ${e.toString()}';
    }
    notifyListeners();
  }

  // ─── Selection Logic ───────────────────────────────────────────────

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedContactIds.clear();
    }
    notifyListeners();
  }

  void toggleSelectContact(String id) {
    if (_selectedContactIds.contains(id)) {
      _selectedContactIds.remove(id);
      // Auto-exit selection mode if no items left
      if (_selectedContactIds.isEmpty) {
        _isSelectionMode = false;
      }
    } else {
      _selectedContactIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedContactIds.clear();
    for (final contact in _filteredContacts) {
      _selectedContactIds.add(contact.id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedContactIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  Future<void> deleteSelectedContacts() async {
    if (_selectedContactIds.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // Note: Ideal would be a batch delete API, but falling back to loop for now
      for (final id in _selectedContactIds) {
        await _contactRepository.delete(id);
        _allContacts.removeWhere((c) => c.id == id);
      }
      _selectedContactIds.clear();
      _isSelectionMode = false;
      _applyFilters();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Xóa hàng loạt thất bại: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Apply both Search and Category filters
  void _applyFilters() {
    _filteredContacts = _allContacts.where((contact) {
      // 1. Category Filter
      bool matchesCategory = true;
      if (_selectedCategory != 'Tất cả') {
        matchesCategory = _mapCategoryToUI(contact.category.toDbString) == _selectedCategory;
      }

      // 2. Search Query Filter (Name, Nickname, or Phone)
      bool matchesSearch = true;
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final phoneSearch = contact.phone.replaceAll(' ', '').toLowerCase();
        final queryPhone = query.replaceAll(' ', '');
        matchesSearch =
            contact.fullName.toLowerCase().contains(query) ||
            (contact.nickname?.toLowerCase().contains(query) ?? false) ||
            phoneSearch.contains(queryPhone);
      }

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Helper to convert DB category to UI Vietnamese category
  String _mapCategoryToUI(String dbCategory) {
    switch (dbCategory) {
      case 'FAMILY': return 'Gia đình';
      case 'BOSS': return 'Sếp';
      case 'COLLEAGUE': return 'Đồng nghiệp';
      case 'PARTNER': return 'Đối tác';
      case 'FRIEND': return 'Bạn bè';
      case 'TEACHER': return 'Thầy cô';
      case 'NEIGHBOR': return 'Hàng xóm';
      case 'OTHER':
      default: return 'Khác';
    }
  }
}