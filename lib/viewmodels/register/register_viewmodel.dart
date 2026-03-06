import 'package:flutter/cupertino.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iauth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final IAuthRepository repository;

  RegisterViewModel({required this.repository});

  bool isLoading = false;
  String? error;

  Future<bool> register({
    required String userName,
    required String password,
    required String confirmPassword,
    required String fullName,
    String phone = '',
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final u = userName.trim();
      final p = password.trim();
      final cp = confirmPassword.trim();
      final fn = fullName.trim();
      final ph = phone.trim();

      if (u.isEmpty || p.isEmpty || cp.isEmpty || fn.isEmpty) {
        throw Exception('Vui lòng điền đầy đủ các thông tin bắt buộc (Username, Password, Confirm Password, Họ và tên)');
      }

      if (p != cp) {
        throw Exception('Mật khẩu nhập lại không khớp');
      }

      if (p.length < 6) {
        throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
      }

      await repository.register(
        userName: u,
        password: p,
        fullName: fn,
        phone: ph.isEmpty ? null : ph,
      );

      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '').replaceFirst('Exception', '').trim();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }
}
