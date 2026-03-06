import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionItem(Icons.person_add_alt_1, 'THÊM MỚI', Colors.red[50]!, const Color(0xFFE53935)),
        _buildQuickActionItem(Icons.file_upload_outlined, 'IMPORT', Colors.orange[50]!, Colors.orange[700]!),
        _buildQuickActionItem(Icons.auto_awesome, 'GỢI Ý', Colors.green[50]!, Colors.teal),
        _buildQuickActionItem(Icons.insights, 'THỐNG KÊ', Colors.indigo[50]!, Colors.indigo[400]!),
      ],
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
