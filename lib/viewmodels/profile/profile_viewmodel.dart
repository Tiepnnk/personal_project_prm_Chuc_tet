import 'package:flutter/foundation.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iauth_repository.dart';
import 'package:personal_project_prm/domain/entities/user.dart';
import 'package:personal_project_prm/data/implementations/local/app_database.dart';
import 'package:personal_project_prm/data/implementations/local/password_hasher.dart';

class ProfileViewModel extends ChangeNotifier {
  final IAuthRepository _repository;

  ProfileViewModel({required IAuthRepository repository})
      : _repository = repository;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Ảnh đang chờ xác nhận lưu (chưa lưu vào DB)
  String? _pendingAvatarPath;
  String? get pendingAvatarPath => _pendingAvatarPath;

  void setPendingAvatar(String path) {
    _pendingAvatarPath = path;
    notifyListeners();
  }

  void cancelPendingAvatar() {
    _pendingAvatarPath = null;
    notifyListeners();
  }

  Future<void> savePendingAvatar() async {
    if (_pendingAvatarPath == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final session = await _repository.getCurrentSession();
      if (session == null) throw Exception('Không tìm thấy phiên đăng nhập');
      final userId = session.user.id;
      final db = await AppDatabase.instance.db;
      await db.update('users', {'avatar': _pendingAvatarPath}, where: 'id = ?', whereArgs: [userId]);
      _pendingAvatarPath = null;
      _errorMessage = null;
      await loadUser();
    } catch (e) {
      _errorMessage = 'Không thể lưu ảnh đại diện';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _repository.getCurrentSession();
      if (session != null) {
        _currentUser = session.user;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải thông tin người dùng';
      debugPrint('ProfileViewModel error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    notifyListeners();
  }

  /// Update basic profile fields (full name, phone)
  Future<void> updateProfile({String? fullName, String? phone}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _repository.getCurrentSession();
      if (session == null) throw Exception('Không tìm thấy phiên đăng nhập');
      final userId = session.user.id;
      final db = await AppDatabase.instance.db;
      await db.update('users', {
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
      }, where: 'id = ?', whereArgs: [userId]);
      // reload
      await loadUser();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Cập nhật thông tin thất bại';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change password for current user. Verifies current password.
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      final session = await _repository.getCurrentSession();
      if (session == null) throw Exception('Không tìm thấy phiên đăng nhập');
      final userId = session.user.id;
      final db = await AppDatabase.instance.db;
      final rows = await db.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
      if (rows.isEmpty) throw Exception('Người dùng không tồn tại');
      final storedHash = (rows.first['password_hash'] ?? '').toString();
      final currentHash = PasswordHasher.sha256Hash(currentPassword);
      if (storedHash != currentHash) {
        _errorMessage = 'Mật khẩu hiện tại không đúng';
        return false;
      }
      final newHash = PasswordHasher.sha256Hash(newPassword);
      await db.update('users', {'password_hash': newHash}, where: 'id = ?', whereArgs: [userId]);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Đổi mật khẩu thất bại';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear notification settings for current user (reset to disabled)
  Future<void> clearNotificationSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final session = await _repository.getCurrentSession();
      if (session == null) throw Exception('Không tìm thấy phiên đăng nhập');
      final userId = session.user.id;
      final db = await AppDatabase.instance.db;
      await db.update('user_settings', {'notify_enabled': 0, 'notify_hours': null}, where: 'user_id = ?', whereArgs: [userId]);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể xóa cài đặt thông báo';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
