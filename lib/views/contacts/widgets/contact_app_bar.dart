import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_project_prm/viewmodels/contact/contact_viewmodel.dart';

class ContactAppBar extends StatelessWidget {
  final VoidCallback onAddPressed;

  const ContactAppBar({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isSelectionMode) {
          return _buildSelectionAppBar(context, viewModel);
        }
        return _buildNormalAppBar(context);
      },
    );
  }

  Widget _buildSelectionAppBar(BuildContext context, ContactViewModel viewModel) {
    final count = viewModel.selectedContactIds.length;
    
    return Container(
      color: const Color(0xFFD32F2F), // Theme red color for selection mode
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => viewModel.clearSelection(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Đã chọn $count',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.select_all, color: Colors.white),
            tooltip: 'Chọn tất cả',
            onPressed: () => viewModel.selectAll(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Xóa',
            onPressed: count > 0 ? () => _confirmDelete(context, viewModel, count) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNormalAppBar(BuildContext context) {
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

  void _confirmDelete(BuildContext context, ContactViewModel viewModel, int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa $count liên hệ này không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.deleteSelectedContacts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
