import 'package:personal_project_prm/data/dto/contact_dto.dart';
import 'package:personal_project_prm/data/dto/contacts/update_insert_contact_dto.dart';

abstract class IContactApi {
  Future<List<ContactDto>> getAll();
  Future<ContactDto?> getById(String id);
  Future<void> create(UpdateInsertContactDto req);
  Future<int> update(String id,UpdateInsertContactDto req);
  Future<int> delete(String id);

  Future<void> seedDemoIfEmpty();
}