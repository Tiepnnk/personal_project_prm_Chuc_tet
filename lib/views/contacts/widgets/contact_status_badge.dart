import 'package:flutter/material.dart';

class ContactStatusBadge extends StatelessWidget {
  final String status;

  const ContactStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData iconData;

    switch (status) {
      case 'Đã gọi':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF10B981);
        iconData = Icons.check_circle;
        break;
      case 'Gọi lại':
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFEA580C);
        iconData = Icons.access_time_filled;
        break;
      case 'Chưa gọi':
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        iconData = Icons.hourglass_empty;
        break;
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
          const SizedBox(width: 2),
          Text(
            status,
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
