import 'package:flutter/material.dart';
import 'package:personal_project_prm/views/contacts/add_contact_page.dart';
import 'package:personal_project_prm/views/import_contacts/import_contacts_page.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionItem(
          Icons.person_add_alt_1,
          'THÊM MỚI',
          Colors.red[50]!,
          const Color(0xFFE53935),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddContactPage()),
            );
            if (result == true && context.mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thêm liên hệ thành công!'),
                  backgroundColor: Color(0xFF4CAF50),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        _buildQuickActionItem(Icons.file_upload_outlined, 'IMPORT', Colors.orange[50]!, Colors.orange[700]!,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ImportContactsPage()),
            );
            if (result == true && context.mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Import danh bạ thành công!'),
                  backgroundColor: Color(0xFF4CAF50),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        _buildQuickActionItem(Icons.auto_awesome, 'GỢI Ý', Colors.green[50]!, Colors.teal),
        _buildQuickActionItem(Icons.insights, 'THỐNG KÊ', Colors.indigo[50]!, Colors.indigo[400]!),
      ],
    );
  }

  Widget _buildQuickActionItem(IconData icon, String label, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
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
      ),
    );
  }
}
