import 'package:flutter/foundation.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iauth_repository.dart';
import 'package:personal_project_prm/domain/entities/user.dart';

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
}
