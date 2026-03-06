import 'package:flutter/material.dart';

class ContactPriorityBadge extends StatelessWidget {
  final String priority;

  const ContactPriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (priority) {
      case 'Bắt buộc':
        bgColor = const Color(0xFFFFEBEE); // Đỏ nhạt
        textColor = const Color(0xFFD32F2F);
        break;
      case 'Nên gọi':
        bgColor = const Color(0xFFFFF8E1); // Vàng nhạt
        textColor = const Color(0xFFF57C00);
        break;
      case 'Tùy chọn':
      default:
        bgColor = const Color(0xFFF3F4F6); // Xám nhạt
        textColor = const Color(0xFF4B5563);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
