import 'dart:io';
import 'package:flutter/material.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_action_icon.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_priority_badge.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_status_badge.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  /// Trạng thái chúc Tết lấy từ wish_records, null = chưa có record nào
  final WishStatus? wishStatus;

  // Selection mode fields
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelect;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    this.wishStatus,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onSelect,
  });

  // --- Utility functions ---
  String _getInitials(String fullName) {
    List<String> parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color _getAvatarColorForCategory(String dbCategory) {
    switch (dbCategory) {
      case 'FAMILY': return const Color(0xFFFFCCDF);
      case 'BOSS': return const Color(0xFFE2C9A4);
      case 'COLLEAGUE': return const Color(0xFFD1E4FF);
      case 'PARTNER': return const Color(0xFFFEE2E2);
      case 'FRIEND': return const Color(0xFFC7D2FE);
      case 'TEACHER': return const Color(0xFFD1FAE5);
      case 'NEIGHBOR': return const Color(0xFFFEF3C7);
      case 'OTHER':
      default: return const Color(0xFFE5E7EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initials = _getInitials(contact.fullName);
    final Color avatarColor = _getAvatarColorForCategory(contact.category.toDbString);

    // Convert Enum to UI String mappings
    final String categoryStr = contact.category.displayName.toUpperCase();
    final String priorityStr = contact.priority.displayName;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: const Color(0xFFD32F2F), width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Sử dụng ClipRRect và Material/InkWell để bắt tap cho TOÀN BỘ card
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSelected ? 18.5 : 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isSelectionMode ? onSelect : null,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: IgnorePointer(
                  // Nếu đang ở chế độ chọn, vô hiệu hoá mọi tương tác bên trong (bao gồm ExpansionTile)
                  // để InkWell ở ngoài hứng trọn sự kiện Tap
                  ignoring: isSelectionMode,
                  child: ExpansionTile(
                    maintainState: true,
                    trailing: isSelectionMode ? const SizedBox.shrink() : null,
                    tilePadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        // Avatar OR Checkbox
                        if (isSelectionMode)
                          Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            child: Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade400,
                              size: 32,
                            ),
                          )
                        else
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: avatarColor,
                            backgroundImage: (contact.avatar != null &&
                                    contact.avatar!.isNotEmpty &&
                                    File(contact.avatar!).existsSync())
                                ? FileImage(File(contact.avatar!))
                                : null,
                            child: (contact.avatar == null ||
                                    contact.avatar!.isEmpty ||
                                    !File(contact.avatar!).existsSync())
                                ? Text(
                                    initials,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: initials.length > 1 ? 18 : 22,
                                    ),
                                  )
                                : null,
                          ),
                        const SizedBox(width: 16),
                        
                        // Info Collapsed
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      contact.fullName +
                                          (contact.nickname != null && contact.nickname!.isNotEmpty
                                              ? ' (${contact.nickname})'
                                              : ''),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                categoryStr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ContactPriorityBadge(priority: priorityStr),
                                  const SizedBox(width: 8),
                                  ContactStatusBadge(wishStatus: wishStatus),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    children: isSelectionMode ? [] : [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            // Phone Number
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    contact.phone,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                  Icon(Icons.copy, size: 18, color: Colors.grey[400]),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Action Icons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ContactActionIcon(
                                  icon: Icons.call,
                                  color: const Color(0xFF10B981),
                                  label: 'Gọi điện',
                                  onTap: () {},
                                ),
                                ContactActionIcon(
                                  icon: Icons.info_outline,
                                  color: const Color(0xFF3B82F6),
                                  label: 'Chi tiết',
                                  onTap: () {},
                                ),
                                ContactActionIcon(
                                  icon: Icons.edit_outlined,
                                  color: const Color(0xFFF59E0B),
                                  label: 'Chỉnh sửa',
                                  onTap: onEdit,
                                ),
                                ContactActionIcon(
                                  icon: Icons.delete_outline,
                                  color: const Color(0xFFEF4444),
                                  label: 'Xóa',
                                  onTap: onDelete,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
