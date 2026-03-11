import 'package:flutter/foundation.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iauth_repository.dart';
import 'package:personal_project_prm/data/interfaces/repositories/icontact_repository.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iwish_record_repository.dart';
import 'package:personal_project_prm/domain/entities/user.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class HomeViewModel extends ChangeNotifier {
  final IAuthRepository repository;
  final IContactRepository contactRepository;
  final IWishRecordRepository wishRecordRepository;

  HomeViewModel({
    required this.repository,
    required this.contactRepository,
    required this.wishRecordRepository,
  });

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // ─── Progress Stats ─────────────────────────────────────────────────────────

  int _totalContacts = 0;
  int _calledCount = 0;
  int _messagedCount = 0;

  int get totalContacts => _totalContacts;
  int get calledCount => _calledCount;
  int get messagedCount => _messagedCount;
  int get pendingCount => _totalContacts - _calledCount - _messagedCount;

  /// Số đã chúc = đã gọi + đã nhắn
  int get wishedCount => _calledCount + _messagedCount;

  /// % tiến độ (0.0 → 1.0)
  double get progressPercent =>
      _totalContacts > 0 ? wishedCount / _totalContacts : 0.0;

  /// % tiến độ hiển thị (0 → 100)
  int get progressPercentDisplay => (progressPercent * 100).round();

  // ─── Fetch User + Progress ──────────────────────────────────────────────────

  Future<void> fetchCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await repository.getCurrentSession();
      if (session != null) {
        _currentUser = session.user;
      }

      // Load progress stats from database
      await _loadProgress();
    } catch (e) {
      debugPrint('Error fetching current user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải dữ liệu tiến độ chúc Tết từ SQLite
  Future<void> _loadProgress() async {
    try {
      // Lấy tổng số contacts hiện có (không bao gồm đã xóa)
      final allContacts = await contactRepository.getAll();
      _totalContacts = allContacts.length;

      // Tạo set ID của các contact còn tồn tại
      final existingIds = allContacts.map((c) => c.id).toSet();

      // Lấy map status cho năm hiện tại
      final year = DateTime.now().year;
      final statusMap = await wishRecordRepository.getStatusMapForYear(year);

      // Đếm theo trạng thái, CHỈ tính contact còn tồn tại
      _calledCount = 0;
      _messagedCount = 0;

      for (final entry in statusMap.entries) {
        // Bỏ qua wish_record của contact đã bị xóa
        if (!existingIds.contains(entry.key)) continue;

        if (entry.value == WishStatus.called) {
          _calledCount++;
        } else if (entry.value == WishStatus.messaged) {
          _messagedCount++;
        }
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  /// Gọi lại khi cần refresh progress (ví dụ sau khi chúc Tết)
  Future<void> refreshProgress() async {
    await _loadProgress();
    notifyListeners();
  }

  Future<void> logout() async {
    await repository.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateAvatar(String path) async {
    try {
      await repository.updateAvatar(path);
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(avatar: path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating avatar: $e');
    }
  }
}
