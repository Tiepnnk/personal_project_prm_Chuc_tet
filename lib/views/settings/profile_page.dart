import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

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

  // ─── Avatar Actions ──────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null && mounted) {
        context.read<ProfileViewModel>().setPendingAvatar(file.path);
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
    }
  }

  void _showAvatarOptions(String? avatarPath) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            if (avatarPath != null) ...[
              ListTile(
                leading: const Icon(Icons.remove_red_eye_rounded, color: Colors.blue),
                title: const Text('Xem ảnh đại diện',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showImageFullScreen(avatarPath);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: Text(
                avatarPath != null ? 'Đổi ảnh từ thư viện' : 'Chọn ảnh từ thư viện',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Huỷ', style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.red)),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageFullScreen(String avatarPath) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.file(File(avatarPath), fit: BoxFit.contain),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Show snackbar ───────────────────────────────────────────────────────────

  void _showSnackBar(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: success ? const Color(0xFF4CAF50) : const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
            final savedAvatarPath = user?.avatar;
            // Hiển thị pending nếu có, ngược lại hiển thị avatar đã lưu
            final displayAvatarPath = vm.pendingAvatarPath ?? savedAvatarPath;
            final hasPending = vm.pendingAvatarPath != null;

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
                  _buildHeader(displayAvatarPath, initials, displayName, username, hasPending, vm),
                  const SizedBox(height: 32),

                  // ── MENU GROUP 1 ────────────────────────
                  _buildMenuCard([
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      iconBg: const Color(0xFFFFEDE8),
                      iconColor: const Color(0xFFE57373),
                      label: 'Thông tin cá nhân',
                      onTap: () async {
                        final vm = context.read<ProfileViewModel>();
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider<ProfileViewModel>.value(
                              value: vm,
                              child: const PersonalInfoPage(),
                            ),
                          ),
                        );
                        if (result == true && mounted) {
                          _showSnackBar('Cập nhật thông tin thành công ✓', success: true);
                        }
                      },
                    ),
                    _MenuItem(
                      icon: Icons.lock_outline_rounded,
                      iconBg: const Color(0xFFFFEDE8),
                      iconColor: const Color(0xFFE57373),
                      label: 'Đổi mật khẩu',
                      onTap: () async {
                        final vm = context.read<ProfileViewModel>();
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider<ProfileViewModel>.value(
                              value: vm,
                              child: const ChangePasswordPage(),
                            ),
                          ),
                        );
                        if (result == true && mounted) {
                          _showSnackBar('Đổi mật khẩu thành công ✓', success: true);
                        }
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
      String? displayAvatarPath,
      String initials,
      String displayName,
      String username,
      bool hasPending,
      ProfileViewModel vm) {
    final hasAvatar = displayAvatarPath != null &&
        displayAvatarPath.isNotEmpty &&
        File(displayAvatarPath).existsSync();

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

        // Avatar với tap để chọn ảnh
        GestureDetector(
          onTap: () => _showAvatarOptions(hasAvatar ? displayAvatarPath : null),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasPending ? const Color(0xFFD32F2F) : const Color(0xFFE8C99A),
                    width: hasPending ? 3.5 : 3,
                  ),
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
                  backgroundImage: hasAvatar ? FileImage(File(displayAvatarPath!)) : null,
                  child: !hasAvatar
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
              // Camera icon overlay
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: hasPending ? const Color(0xFFD32F2F) : Colors.grey[100],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: hasPending ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Action bar khi có pending avatar
        if (hasPending) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: vm.cancelPendingAvatar,
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Hủy'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  await vm.savePendingAvatar();
                  if (mounted) {
                    if (vm.errorMessage == null) {
                      _showSnackBar('Cập nhật ảnh đại diện thành công ✓', success: true);
                    } else {
                      _showSnackBar(vm.errorMessage!, success: false);
                    }
                  }
                },
                icon: const Icon(Icons.save_alt, size: 16),
                label: const Text('Lưu ảnh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ảnh chưa được lưu – nhấn "Lưu ảnh" để xác nhận',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ] else
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
