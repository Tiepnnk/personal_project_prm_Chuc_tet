import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_project_prm/di.dart';
import 'package:personal_project_prm/viewmodels/profile/profile_viewmodel.dart';
import 'package:personal_project_prm/views/settings/personal_info_page.dart';
import 'package:personal_project_prm/views/settings/change_password_page.dart';
import 'package:personal_project_prm/views/settings/about_page.dart';
import 'package:personal_project_prm/views/settings/help_support_page.dart';
import 'package:personal_project_prm/views/widgets/app_bottom_nav.dart';

// ─── Wrapper (Provider) ───────────────────────────────────────────────────────

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => buildProfileVM(),
      child: const _ProfileView(),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUser();
    });
  }

  // ─── Logout ─────────────────────────────────────────────────────────────────

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child:
                const Text('Hủy', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Đăng xuất',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ProfileViewModel>().logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      body: SafeArea(
        child: Consumer<ProfileViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
              );
            }

            final user = vm.currentUser;
            final displayName =
                (user?.fullName?.isNotEmpty == true) ? user!.fullName! : (user?.userName ?? 'Người dùng');
            final username = '@${user?.userName ?? 'unknown'}';
            final avatarPath = user?.avatar;

            // Initials for fallback avatar
            final initials = displayName.trim().isNotEmpty
                ? displayName.trim().split(' ').length >= 2
                    ? '${displayName.trim().split(' ').first[0]}${displayName.trim().split(' ').last[0]}'.toUpperCase()
                    : displayName.trim()[0].toUpperCase()
                : '?';

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── HEADER ──────────────────────────────
                  _buildHeader(avatarPath, initials, displayName, username),
                  const SizedBox(height: 32),

                  // ── MENU GROUP 1 ────────────────────────
                  _buildMenuCard([
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      iconBg: const Color(0xFFFFEDE8),
                      iconColor: const Color(0xFFE57373),
                      label: 'Thông tin cá nhân',
                      onTap: () {
                        final vm = context.read<ProfileViewModel>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider<ProfileViewModel>.value(
                              value: vm,
                              child: const PersonalInfoPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline_rounded,
                      iconBg: const Color(0xFFFFEDE8),
                      iconColor: const Color(0xFFE57373),
                      label: 'Đổi mật khẩu',
                      onTap: () {
                        final vm = context.read<ProfileViewModel>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider<ProfileViewModel>.value(
                              value: vm,
                              child: const ChangePasswordPage(),
                            ),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // ── MENU GROUP 2 ────────────────────────
                  _buildMenuCard([
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      iconBg: const Color(0xFFE8F0FF),
                      iconColor: const Color(0xFF5C8EFF),
                      label: 'Về ứng dụng',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
                    ),
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      iconBg: const Color(0xFFEDE8FF),
                      iconColor: const Color(0xFF9575CD),
                      label: 'Trợ giúp & Hỗ trợ',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage())),
                      hasDivider: false,
                    ),
                  ]),
                  const SizedBox(height: 28),

                  // ── LOGOUT BUTTON ───────────────────────
                  _buildLogoutButton(),
                  const SizedBox(height: 20),

                  // ── VERSION ─────────────────────────────
                  Text(
                    '🌸 Phiên bản 2.0.26 (Tết Bính Ngọ) 🌸',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: NavIndex.settings),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(
      String? avatarPath, String initials, String displayName, String username) {
    return Column(
      children: [
        // Decorative top cherry blossom row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.spa, color: Colors.red.shade200, size: 20),
            Icon(Icons.spa, color: Colors.pink.shade100, size: 16),
          ],
        ),
        const SizedBox(height: 8),

        // Avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8C99A), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 52,
            backgroundColor: const Color(0xFFFFF3E0),
            backgroundImage: (avatarPath != null &&
                    avatarPath.isNotEmpty &&
                    File(avatarPath).existsSync())
                ? FileImage(File(avatarPath))
                : null,
            child: (avatarPath == null ||
                    avatarPath.isEmpty ||
                    !File(avatarPath).existsSync())
                ? Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),

        // Full name
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD84315),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Username
        Text(
          username,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ─── Menu Card ───────────────────────────────────────────────────────────────

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) => _buildMenuTile(item)).toList(),
      ),
    );
  }

  Widget _buildMenuTile(_MenuItem item) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: item.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 22),
                  ),
                  const SizedBox(width: 16),

                  // Label
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),

                  // Arrow
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey.shade400, size: 22),
                ],
              ),
            ),
          ),
        ),
        if (item.hasDivider)
          Divider(
            height: 1,
            indent: 74,
            endIndent: 16,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }

  // ─── Logout Button ───────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _onLogout,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 22),
                SizedBox(width: 10),
                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

// ─── Data model for menu items ────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool hasDivider;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.hasDivider = true,
  });
}
