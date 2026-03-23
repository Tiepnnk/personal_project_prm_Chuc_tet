import 'dart:io';
import 'package:flutter/material.dart';
import 'package:personal_project_prm/viewmodels/home/home_viewmodel.dart';

class HomeHeader extends StatelessWidget {
  final HomeViewModel viewModel;
  final void Function(BuildContext context, String? avatarPath) onAvatarTap;

  const HomeHeader({
    super.key,
    required this.viewModel,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayedName = viewModel.currentUser?.fullName ?? viewModel.currentUser?.userName ?? 'Người dùng';
    final avatarPath = viewModel.currentUser?.avatar;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào,',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                displayedName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Avatar – chỉ hiển thị, tap để xem fullscreen
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onAvatarTap(context, avatarPath),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange[300]!, width: 2),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.orange[50],
              backgroundImage: avatarPath != null ? FileImage(File(avatarPath)) : null,
              child: avatarPath == null
                  ? const Icon(Icons.person, color: Colors.grey, size: 36)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
