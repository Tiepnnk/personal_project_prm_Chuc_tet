import 'package:flutter/foundation.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iauth_repository.dart';
import 'package:personal_project_prm/domain/entities/user.dart';

class HomeViewModel extends ChangeNotifier {
  final IAuthRepository repository;

  HomeViewModel({required this.repository});

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await repository.getCurrentSession();
      if (session != null) {
        _currentUser = session.user;
      }
    } catch (e) {
      debugPrint('Error fetching current user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
