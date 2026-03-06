import 'package:personal_project_prm/domain/entities/contact.dart';

abstract class IContactRepository {
  Future<void> seedDemoIfEmpty();

  Future<List<Contact>> getAll();
  Future<Contact?> getById(String id);
  Future<Contact> create(String fullName,String? nickName,String phone,String category,
      String priority,String? note,String? avatar,int active);
  Future<Contact> update(String id,String fullName,String? nickName,String phone,String category,
      String priority,String? note,String? avatar,int active);
  Future<void>  delete(String id);
}