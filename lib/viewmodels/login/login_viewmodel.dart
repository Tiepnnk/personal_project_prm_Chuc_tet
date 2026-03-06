import 'package:flutter/cupertino.dart';
import 'package:personal_project_prm/data/implementations/repositories/auth_repository.dart';
import 'package:personal_project_prm/domain/entities/auth_session.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository repository;
  LoginViewModel({required this.repository});

  bool isLoading = false;
  String? error ;
  AuthSession? authSession;


  Future<bool> login(String userName, String password) async{
    isLoading = true;
    error = null;
    notifyListeners();

    try{
      final u = userName.trim();
      final p = password.trim();

      if(u.isEmpty || p.isEmpty) throw Exception('Please enter username and password');
      authSession = await repository.login(u, p); // trả Entity
      return true;
    } catch(e){
      authSession = null;
      error = e.toString().replaceFirst('Exception', '');
      return false;
    }finally{
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async{
    await repository.logout();
    authSession = null;
    notifyListeners();
  }

  void clearError(){
    if(error != null){
      error = null;
      notifyListeners();
    }
  }
}