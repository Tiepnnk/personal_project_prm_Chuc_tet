import 'package:flutter/material.dart';

class TetInfoCard extends StatelessWidget {
  const TetInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: Color(0xFFD32F2F)),
          const SizedBox(width: 12),
          const Text(
            'Xuân Bính Ngọ — Tết 2026',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Text(
            'HÔM NAY',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
