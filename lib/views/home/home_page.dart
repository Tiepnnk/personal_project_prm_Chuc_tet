import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personal_project_prm/viewmodels/home/home_viewmodel.dart';
import 'package:personal_project_prm/views/widgets/falling_blossom_widget.dart';
import 'package:personal_project_prm/views/widgets/lucky_money_widget.dart';
import 'package:personal_project_prm/views/contacts/contact_page.dart';
import 'package:personal_project_prm/views/settings/profile_page.dart';
import 'package:personal_project_prm/views/home/widgets/home_header.dart';
import 'package:personal_project_prm/views/home/widgets/tet_info_card.dart';
import 'package:personal_project_prm/views/home/widgets/progress_card.dart';
import 'package:personal_project_prm/views/home/widgets/quick_actions.dart';
import 'package:personal_project_prm/views/home/widgets/priority_section.dart';
import 'package:personal_project_prm/views/home/widgets/reminder_banner.dart';
import 'package:provider/provider.dart';

/// Màn hình chính sau khi đăng nhập thành công
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Biến cờ (flag) để cho phép bật/tắt hiệu ứng Tết nếu muốn
  bool _enableTetEffect = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchCurrentUser();
    });
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && context.mounted) {
        await context.read<HomeViewModel>().updateAvatar(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
    }
  }

  // Hàm hiển thị Popup xem ảnh Fullscreen
  void _showImageFullScreen(BuildContext context, String avatarPath) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hàm BottomSheet tuỳ chọn cho Avatar
  void _showAvatarOptions(BuildContext context, String? avatarPath) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
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
                  title: const Text('Xem ảnh đại diện', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showImageFullScreen(context, avatarPath);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Đổi ảnh từ thư viện', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickImage(context);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Chọn ảnh từ thư viện', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickImage(context);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Huỷ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                onTap: () => Navigator.pop(bottomSheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLuckyMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.red[50],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/5770/5770857.png', // Icon Li Xi placeholder
                height: 80,
                errorBuilder: (_, __, ___) => const Icon(Icons.wallet_giftcard, size: 80, color: Colors.red),
              ),
              const SizedBox(height: 16),
              const Text(
                'CHÚC MỪNG NĂM MỚI!',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Chúc bạn một năm Bính Ngọ 2026 bình an, tài lộc và đầy ắp niềm vui cùng ứng dụng quản lý Lời Chúc Tết!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Nhận Lộc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5), // Nền màu vàng kem nhạt
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Giao diện chính bên dưới cùng
            Consumer<HomeViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeHeader(
                        viewModel: viewModel,
                        onAvatarTap: (ctx, path) => _showAvatarOptions(ctx, path),
                        onLogout: (ctx) async {
                          await viewModel.logout();
                          if (ctx.mounted) {
                            Navigator.pushReplacementNamed(ctx, '/login');
                          }
                        },
                      ),
                      const TetInfoCard(),
                      const SizedBox(height: 24),
                      const ProgressCard(),
                      const SizedBox(height: 24),
                      const QuickActions(),
                      const SizedBox(height: 32),
                      const PrioritySection(),
                      const ReminderBanner(),
                    ],
                  ),
                );
              },
            ),

            // 2. Lớp Hoa Đào rơi (Falling Blossom Effect)
            if (_enableTetEffect)
              const FallingBlossomWidget(),

            // 3. Bao Lì xì góc màn hình chớp chớp
            if (_enableTetEffect)
              LuckyMoneyWidget(onTap: _showLuckyMoneyDialog),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBottomNavItem(Icons.home_filled, 'Trang chủ', true, () {}),
            _buildBottomNavItem(Icons.contacts, 'Danh bạ', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactPage()),
              );
            }),
            const SizedBox(width: 48), // Khoảng trống cho FAB
            _buildBottomNavItem(Icons.pie_chart, 'Tiến độ', false, () {}),
            _buildBottomNavItem(Icons.settings, 'Cài đặt', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFD32F2F) : Colors.grey[400],
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? const Color(0xFFD32F2F) : Colors.grey[500],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
