import 'package:flutter/material.dart';
import 'package:personal_project_prm/data/interfaces/repositories/icontact_repository.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class ContactViewModel extends ChangeNotifier {
  final IContactRepository _contactRepository;

  ContactViewModel({required IContactRepository contactRepository})
      : _contactRepository = contactRepository;

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  // Getters
  List<Contact> get filteredContacts => _filteredContacts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

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

  /// Initialize and load all contacts
  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Gọi hàm này để tự động chèn dữ liệu mẫu nếu DB danh bạ đang trống
      await _contactRepository.seedDemoIfEmpty();
      
      _allContacts = await _contactRepository.getAll();
      _applyFilters();
    } catch (e) {
      print('Error loading contacts: $e'); // Print to console if error
      // Could handle error state here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      _applyFilters();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Xóa liên hệ thất bại: ${e.toString()}';
    }
    notifyListeners();
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
        
        // Remove spaces for phone search
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