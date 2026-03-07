import 'package:flutter/material.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iwish_template_repository.dart';
import 'package:personal_project_prm/domain/entities/wish_template.dart';

// Danh sách filter category (phải khớp với UI wish_template_page.dart)
const _filterCategories = [
  'Tất cả',
  'Gia đình',
  'Bạn bè',
  'Sếp',
  'Đồng nghiệp',
  'Đối tác',
  'Thầy cô',
  'Khác',
];

// Map từ display name → giá trị lưu trong DB (targetGroups JSON)
const _categoryToDbKey = {
  'Gia đình': 'FAMILY',
  'Bạn bè': 'FRIEND',
  'Sếp': 'BOSS',
  'Đồng nghiệp': 'COLLEAGUE',
  'Đối tác': 'PARTNER',
  'Thầy cô': 'TEACHER',
  'Khác': 'OTHER',
};

class WishTemplateViewModel extends ChangeNotifier {
  final IWishTemplateRepository _repository;

  WishTemplateViewModel({required IWishTemplateRepository repository})
      : _repository = repository;

  // ─── State ───────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _errorMessage;
  List<WishTemplate> _templates = [];
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  bool _sortByUsage = false;
  bool _showOnlyFavorites = false;

  // ─── Getters ─────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedCategoryIndex => _selectedCategoryIndex;
  String get searchQuery => _searchQuery;
  bool get sortByUsage => _sortByUsage;
  bool get showOnlyFavorites => _showOnlyFavorites;

  List<WishTemplate> get filteredTemplates {
    var result = _templates;

    // 1. Lọc theo category
    if (_selectedCategoryIndex > 0) {
      final categoryName = _filterCategories[_selectedCategoryIndex];
      final dbKey = _categoryToDbKey[categoryName]?.toUpperCase() ?? categoryName.toUpperCase();
      result = result.where((t) => t.targetGroups.any((g) => g.toUpperCase().contains(dbKey))).toList();
    }

    // 2. Lọc theo tìm kiếm (tiêu đề)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(query)).toList();
    }

    // 3. Lọc theo favorite
    if (_showOnlyFavorites) {
      result = result.where((t) => t.isFavorite).toList();
    }

    // 4. Sắp xếp theo số lần dùng
    if (_sortByUsage) {
      result = List.from(result)..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    }

    return result;
  }

  // ─── Methods ─────────────────────────────────────────────────────────────────

  Future<void> loadTemplates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _templates = await _repository.getAll();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách lời chúc: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onCategorySelected(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSortByUsage() {
    _sortByUsage = !_sortByUsage;
    notifyListeners();
  }

  void toggleShowOnlyFavorites() {
    _showOnlyFavorites = !_showOnlyFavorites;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id, bool currentValue) async {
    try {
      await _repository.toggleFavorite(id, !currentValue);
      // Cập nhật local state để UI phản hồi ngay, không cần reload toàn bộ
      final idx = _templates.indexWhere((t) => t.id == id);
      if (idx != -1) {
        final old = _templates[idx];
        _templates[idx] = WishTemplate(
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

  Future<void> deleteTemplate(String id) async {
    try {
      await _repository.delete(id);
      _templates.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể xóa mẫu lời chúc: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
