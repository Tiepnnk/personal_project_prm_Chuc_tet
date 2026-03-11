import 'package:personal_project_prm/data/dto/contacts/update_insert_contact_dto.dart';
import 'package:personal_project_prm/data/implementations/mapper/contact_mapper.dart';
import 'package:personal_project_prm/data/interfaces/api/icontact_api.dart';
import 'package:personal_project_prm/data/interfaces/repositories/iauth_repository.dart';
import 'package:personal_project_prm/data/interfaces/repositories/icontact_repository.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';

class ContactRepository implements IContactRepository {
  final IContactApi contactApi;
  final ContactMapper contactMapper; // We cast it to ContactMapper to use mapToDto
  final IAuthRepository authRepository;

  const ContactRepository({
    required this.contactApi,
    required this.contactMapper,
    required this.authRepository,
  });

  @override
  Future<Contact> create(
    String fullName,
    String? nickName,
    String phone,
    String category,
    String priority,
    String? note,
    String? avatar,
    int active,
  ) async {
    // 1. Fetch current logged-in user's session to get the actual userId
    final session = await authRepository.getCurrentSession();
    if (session == null) {
      throw Exception('User is not logged in');
    }

    final int currentUserId = session.user.id;

    // 2. Create DTO using dynamically fetched currentUserId
    final insertDto = UpdateInsertContactDto(
      userId: currentUserId, 
      fullName: fullName,
      nickname: nickName,
      phone: phone,
      category: category,
      priority: priority,
      note: note,
      avatar: avatar,
      isActive: active,
    );

    // 3. Call API to insert and get the new contact's ID
    final newId = await contactApi.create(insertDto);

    // 4. Fetch the newly created contact by ID (efficient single-row query)
    final newContactDto = await contactApi.getById(newId);
    if (newContactDto == null) {
      throw Exception('Failed to retrieve newly created contact');
    }

    // 5. Map back to domain entity
    return contactMapper.map(newContactDto);
  }

  @override
  Future<void> delete(String id) async {
    await contactApi.delete(id);
  }

  @override
  Future<List<Contact>> getAll() async {
    final session = await authRepository.getCurrentSession();
    if (session == null) {
      throw Exception('User is not logged in');
    }

    final int currentUserId = session.user.id;
    
    final dtoList = await contactApi.getAll();
    
    // Filter contacts to only those belonging to the current user
    final userContacts = dtoList.where((dto) => dto.userId == currentUserId).toList();
    
    return userContacts.map((dto) => contactMapper.map(dto)).toList();
  }

  @override
  Future<Contact?> getById(String id) async {
    final dto = await contactApi.getById(id);
    if (dto != null) {
      // Also verify that this contact belongs to the current user
      final session = await authRepository.getCurrentSession();
      if (session != null && dto.userId == session.user.id) {
        return contactMapper.map(dto);
      }
    }
    return null;
  }

  @override
  Future<void> seedDemoIfEmpty() async {
    await contactApi.seedDemoIfEmpty();
  }

  @override
  Future<Contact> update(
    String id,
    String fullName,
    String? nickName,
    String phone,
    String category,
    String priority,
    String? note,
    String? avatar,
    int active,
  ) async {
     // Fetch the existing contact to access current state (like userId)
    final existingContact = await contactApi.getById(id);
    if (existingContact == null) {
      throw Exception('Contact not found');
    }
    
    // Verify that the contact belongs to the currently logged in user
    final session = await authRepository.getCurrentSession();
    if (session == null || existingContact.userId != session.user.id) {
        throw Exception('Unauthorized to update this contact');
    }

    final updateDto = UpdateInsertContactDto(
      userId: existingContact.userId,
      fullName: fullName,
      nickname: nickName,
      phone: phone,
      category: category,
      priority: priority,
      note: note,
      avatar: avatar,
      isActive: active,
    );

    await contactApi.update(id, updateDto);

    // Fetch the updated DTO to return the latest entity
    final updatedDto = await contactApi.getById(id);
    return contactMapper.map(updatedDto!);
  }
}