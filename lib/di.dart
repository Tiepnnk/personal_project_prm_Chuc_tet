import 'package:personal_project_prm/data/implementations/api/auth_api.dart';
import 'package:personal_project_prm/data/implementations/local/app_database.dart';
import 'package:personal_project_prm/data/implementations/mapper/auth_mapper.dart';
import 'package:personal_project_prm/data/implementations/repositories/auth_repository.dart';
import 'package:personal_project_prm/viewmodels/home/home_viewmodel.dart';
import 'package:personal_project_prm/viewmodels/login/login_viewmodel.dart';
import 'package:personal_project_prm/viewmodels/register/register_viewmodel.dart';
import 'package:personal_project_prm/viewmodels/contact/contact_viewmodel.dart';
import 'package:personal_project_prm/viewmodels/contact/add_contact_viewmodel.dart';
import 'package:personal_project_prm/viewmodels/profile/profile_viewmodel.dart';
import 'package:personal_project_prm/data/implementations/api/contact_api.dart';
import 'package:personal_project_prm/data/implementations/mapper/contact_mapper.dart';
import 'package:personal_project_prm/data/implementations/repositories/contact_repository.dart';

LoginViewModel buildLoginVM(){
  // final authApi = AuthApi(); // implements AuthApi
  final authApi = AuthApi(AppDatabase.instance); // implements AuthApi
  final authSessionMapper = AuthSessionMapper(); // DTO =>Entity
  final authRepository = AuthRepository(api: authApi, mapper: authSessionMapper);// implements AuthRepository
  return LoginViewModel(repository: authRepository);
}

RegisterViewModel buildRegisterVM() {
  final authApi = AuthApi(AppDatabase.instance);
  final authSessionMapper = AuthSessionMapper();
  final authRepository = AuthRepository(api: authApi, mapper: authSessionMapper);
  return RegisterViewModel(repository: authRepository);
}

HomeViewModel buildHomeVM() {
  final authApi = AuthApi(AppDatabase.instance);
  final authSessionMapper = AuthSessionMapper();
  final authRepository = AuthRepository(api: authApi, mapper: authSessionMapper);
  return HomeViewModel(repository: authRepository);
}

ContactViewModel buildContactVM() {
  final authApi = AuthApi(AppDatabase.instance);
  final authSessionMapper = AuthSessionMapper();
  final authRepository = AuthRepository(api: authApi, mapper: authSessionMapper);
  
  final contactApi = ContactApi(AppDatabase.instance);
  final contactMapper = ContactMapper();
  final contactRepository = ContactRepository(
    contactApi: contactApi, 
    contactMapper: contactMapper,
    authRepository: authRepository,
  );

  return ContactViewModel(contactRepository: contactRepository);
}

AddContactViewModel buildAddContactVM() {
  final authApi = AuthApi(AppDatabase.instance);
  final authSessionMapper = AuthSessionMapper();
  final authRepository = AuthRepository(api: authApi, mapper: authSessionMapper);

  final contactApi = ContactApi(AppDatabase.instance);
  final contactMapper = ContactMapper();
  final contactRepository = ContactRepository(
    contactApi: contactApi,
    contactMapper: contactMapper,
    authRepository: authRepository,
  );

  return AddContactViewModel(contactRepository: contactRepository);
}

ProfileViewModel buildProfileVM() {
  final authApi = AuthApi(AppDatabase.instance);
  final authSessionMapper = AuthSessionMapper();
  final authRepository = AuthRepository(api: authApi, mapper: authSessionMapper);
  return ProfileViewModel(repository: authRepository);
}
