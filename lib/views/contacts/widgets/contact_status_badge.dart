import 'package:flutter/material.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';

class ContactStatusBadge extends StatelessWidget {
  /// Trạng thái chúc Tết thực tế từ wish_records, null = chưa có record nào
  final WishStatus? wishStatus;

  const ContactStatusBadge({super.key, this.wishStatus});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData iconData;
    String label;

    if (wishStatus == WishStatus.called) {
      bgColor = const Color(0xFFECFDF5);
      textColor = const Color(0xFF10B981);
      iconData = Icons.check_circle;
      label = 'Đã gọi';
    } else if (wishStatus == WishStatus.messaged) {
      bgColor = const Color(0xFFEFF6FF);
      textColor = const Color(0xFF3B82F6);
      iconData = Icons.mark_chat_read;
      label = 'Đã nhắn';
    } else {
      // WishStatus.pending hoặc null (chưa có record)
      bgColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF6B7280);
      iconData = Icons.hourglass_empty;
      label = 'Chưa gọi';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 10, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

