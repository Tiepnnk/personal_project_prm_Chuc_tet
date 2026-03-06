import 'package:personal_project_prm/data/dto/contact_dto.dart';
import 'package:personal_project_prm/data/interfaces/mapper/imapper.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class ContactMapper implements IMapper<ContactDto, Contact> {
  @override
  Contact map(ContactDto input) {
    return Contact(
      id: input.id,
      userId: input.userId,
      fullName: input.fullName,
      nickname: input.nickname,
      avatar: input.avatar,
      phone: input.phone,
      category: ContactCategoryExtension.fromDbString(input.category),
      priority: ContactPriorityExtension.fromDbString(input.priority),
      note: input.note,
      isActive: input.isActive == 1,
    );
  }

  ContactDto mapToDto(Contact contact) {
    return ContactDto(
      id: contact.id,
      userId: contact.userId,
      fullName: contact.fullName,
      nickname: contact.nickname,
      avatar: contact.avatar,
      phone: contact.phone,
      category: contact.category.toDbString,
      priority: contact.priority.toDbString,
      note: contact.note,
      isActive: contact.isActive ? 1 : 0,
    );
  }
}
