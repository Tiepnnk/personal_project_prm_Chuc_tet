import 'dart:io';
import 'package:flutter/material.dart';
import 'package:personal_project_prm/viewmodels/home/home_viewmodel.dart';
import 'package:personal_project_prm/views/widgets/falling_blossom_widget.dart';
import 'package:personal_project_prm/views/widgets/lucky_money_widget.dart';
import 'package:personal_project_prm/views/home/widgets/home_header.dart';
import 'package:personal_project_prm/views/home/widgets/tet_info_card.dart';
import 'package:personal_project_prm/views/home/widgets/progress_card.dart';
import 'package:personal_project_prm/views/home/widgets/quick_actions.dart';
import 'package:personal_project_prm/views/home/widgets/priority_section.dart';
import 'package:personal_project_prm/views/home/widgets/reminder_banner.dart';
import 'package:personal_project_prm/views/widgets/app_bottom_nav.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchCurrentUser();
    });
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

  void _showLuckyMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.red[50],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/5770/5770857.png',
                height: 80,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.wallet_giftcard, size: 80, color: Colors.red),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Nhận Lộc', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Giao diện chính bên dưới cùng
            Consumer<HomeViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator(
                      color: Color(0xFFD32F2F)));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeHeader(
                        viewModel: viewModel,
                        onAvatarTap: (ctx, path) {
                          // Chỉ xem fullscreen nếu có ảnh
                          if (path != null && path.isNotEmpty) {
                            _showImageFullScreen(ctx, path);
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
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          '🌸 Phiên bản 2.0.26 (Tết Bính Ngọ) 🌸',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
      bottomNavigationBar: const AppBottomNav(currentIndex: NavIndex.home),
    );
  }
}
