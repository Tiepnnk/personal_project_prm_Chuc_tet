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
import 'package:personal_project_prm/data/implementations/api/wish_template_api.dart';
import 'package:personal_project_prm/data/implementations/mapper/wish_template_mapper.dart';
import 'package:personal_project_prm/data/implementations/repositories/wish_template_repository.dart';
import 'package:personal_project_prm/viewmodels/wish_template/wish_template_viewmodel.dart';
import 'package:personal_project_prm/viewmodels/wish_template/create_wish_template_viewmodel.dart';
import 'package:personal_project_prm/data/implementations/api/wish_record_api.dart';
import 'package:personal_project_prm/data/implementations/mapper/wish_record_mapper.dart';
import 'package:personal_project_prm/data/implementations/repositories/wish_record_repository.dart';
import 'package:personal_project_prm/viewmodels/wish/wish_viewmodel.dart';

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

  final wishRecordApi = WishRecordApi(AppDatabase.instance);
  final wishRecordMapper = WishRecordMapper();
  final wishRecordRepository = WishRecordRepository(
    wishRecordApi: wishRecordApi,
    wishRecordMapper: wishRecordMapper,
  );

  return ContactViewModel(
    contactRepository: contactRepository,
    wishRecordRepository: wishRecordRepository,
  );
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

WishTemplateViewModel buildWishTemplateVM() {
  final authApi = AuthApi(AppDatabase.instance);
  final authSessionMapper = AuthSessionMapper();
  final authRepository = AuthRepository(api: authApi, mapper: authSessionMapper);

  final wishTemplateApi = WishTemplateApi(AppDatabase.instance);
  final wishTemplateMapper = WishTemplateMapper();
  final wishTemplateRepository = WishTemplateRepository(
    wishTemplateApi: wishTemplateApi,
    wishTemplateMapper: wishTemplateMapper,
    authRepository: authRepository,
  );

  return WishTemplateViewModel(repository: wishTemplateRepository);
}

CreateWishTemplateViewModel buildCreateWishTemplateVM() {
  final authApi = AuthApi(AppDatabase.instance);
  final authSessionMapper = AuthSessionMapper();
  final authRepository = AuthRepository(api: authApi, mapper: authSessionMapper);

  final wishTemplateApi = WishTemplateApi(AppDatabase.instance);
  final wishTemplateMapper = WishTemplateMapper();
  final wishTemplateRepository = WishTemplateRepository(
    wishTemplateApi: wishTemplateApi,
    wishTemplateMapper: wishTemplateMapper,
    authRepository: authRepository,
  );

  return CreateWishTemplateViewModel(repository: wishTemplateRepository);
}

WishViewModel buildWishVM() {
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

  final wishTemplateApi = WishTemplateApi(AppDatabase.instance);
  final wishTemplateMapper = WishTemplateMapper();
  final wishTemplateRepository = WishTemplateRepository(
    wishTemplateApi: wishTemplateApi,
    wishTemplateMapper: wishTemplateMapper,
    authRepository: authRepository,
  );

  final wishRecordApi = WishRecordApi(AppDatabase.instance);
  final wishRecordMapper = WishRecordMapper();
  final wishRecordRepository = WishRecordRepository(
    wishRecordApi: wishRecordApi,
    wishRecordMapper: wishRecordMapper,
  );

  return WishViewModel(
    contactRepository: contactRepository,
    wishTemplateRepository: wishTemplateRepository,
    wishRecordRepository: wishRecordRepository,
  );
}
