import 'dart:io';
import 'package:flutter/material.dart';
import 'package:personal_project_prm/viewmodels/home/home_viewmodel.dart';

class HomeHeader extends StatelessWidget {
  final HomeViewModel viewModel;
  final void Function(BuildContext context, String? avatarPath) onAvatarTap;
  final void Function(BuildContext context) onLogout;

  const HomeHeader({
    super.key,
    required this.viewModel,
    required this.onAvatarTap,
    required this.onLogout,
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
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onAvatarTap(context, avatarPath),
          child: Stack(
            children: [
              Container(
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
              // Camera overlay Icon
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 10,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD32F2F), size: 24),
            onPressed: () => onLogout(context),
            tooltip: 'Đăng xuất',
          ),
        ),
      ],
    );
  }
}
