import 'package:flutter/material.dart';
import 'package:personal_project_prm/domain/entities/wish_template.dart';
import 'package:personal_project_prm/viewmodels/wish/wish_viewmodel.dart';
import 'package:provider/provider.dart';

class ViewDetailWishTemplatePage extends StatelessWidget {
  final WishTemplate template;

  const ViewDetailWishTemplatePage({super.key, required this.template});

  /// Hàm tiện ích để hiển thị trang chi tiết mẫu lời chúc dưới dạng BottomSheet
  static Future<void> show(BuildContext context, WishTemplate template) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ViewDetailWishTemplatePage(template: template),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildHeartIcon(),
                  const SizedBox(height: 24),
                  _buildTitle(),
                  const SizedBox(height: 16),
                  _buildContent(),
                  const SizedBox(height: 32),
                  _buildDots(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 6,
        decoration: BoxDecoration(
          color: const Color(0xFFFFCDD2).withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'CHI TIẾT MẪU LỜI CHÚC',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Color(0xFFE53935),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFFD32F2F)),
              onPressed: () => Navigator.pop(context),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE52040),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE52040).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.favorite, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      template.title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1A1A24),
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Text(
            template.content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Text(
            '\u201C',
            style: TextStyle(
              fontSize: 60,
              fontFamily: 'serif',
              height: 0.8,
              color: const Color(0xFFFFCDD2).withOpacity(0.8),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Text(
            '\u201D',
            style: TextStyle(
              fontSize: 60,
              fontFamily: 'serif',
              height: 0.8,
              color: const Color(0xFFFFCDD2).withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(const Color(0xFFFFE082)),
        const SizedBox(width: 8),
        _buildDot(const Color(0xFFFFC107)),
        const SizedBox(width: 8),
        _buildDot(const Color(0xFFFFE082)),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút Sử dụng mẫu này
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Lưu template vào WishViewModel
                final vm = Provider.of<WishViewModel>(context, listen: false);
                vm.selectTemplate(template);
                // Đóng trang chi tiết
                Navigator.pop(context);
                // Đóng trang danh sách template
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Sử dụng mẫu này',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'TẾT ẤT TỴ 2026 • AN KHANG THỊNH VƯỢNG',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF78909C),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
