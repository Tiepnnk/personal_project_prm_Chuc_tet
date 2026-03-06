import 'package:flutter/material.dart';

class ContactAppBar extends StatelessWidget {
  final VoidCallback onAddPressed;

  const ContactAppBar({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Danh bạ 2026',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.person_add_alt_1,
                color: Color(0xFFD32F2F),
              ),
              onPressed: onAddPressed,
            ),
          ),
        ],
      ),
    );
  }
}
