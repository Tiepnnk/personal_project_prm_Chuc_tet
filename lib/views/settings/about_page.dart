import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // ─── Constants ───────────────────────────────────────────────────────────────
  static const _red = Color(0xFFD32F2F);
  static const _bg = Color(0xFFFCF8F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── App Banner ────────────────────────────────────────────────────
            _buildAppBanner(),
            const SizedBox(height: 28),

            // ── Version Info ──────────────────────────────────────────────────
            _buildLabel('Phiên bản'),
            const SizedBox(height: 10),
            _buildCard([
              _buildInfoTile(
                icon: Icons.new_releases_outlined,
                iconColor: _red,
                iconBg: const Color(0xFFFFEDE8),
                label: 'Phiên bản hiện tại',
                value: '2.0.26',
              ),
              _divider(),
              _buildInfoTile(
                icon: Icons.calendar_today_outlined,
                iconColor: const Color(0xFF1976D2),
                iconBg: const Color(0xFFE3F0FF),
                label: 'Ngày phát hành',
                value: '24/03/2026',
              ),
            ]),
            const SizedBox(height: 20),

            // ── About ─────────────────────────────────────────────────────────
            _buildLabel('Giới thiệu'),
            const SizedBox(height: 10),
            _buildCard([
              _buildInfoTile(
                icon: Icons.apps_rounded,
                iconColor: const Color(0xFF7B61FF),
                iconBg: const Color(0xFFEDE8FF),
                label: 'Tên ứng dụng',
                value: 'Quản lý Lời Chúc Tết',
              ),
              _divider(),
              _buildDescriptionTile(
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBg: const Color(0xFFE8F5E9),
                label: 'Mô tả',
                description:
                    'Ứng dụng quản lý danh bạ và lời chúc Tết thông minh, giúp bạn kết nối và gửi gắm yêu thương đến mọi người.',
              ),
            ]),
            const SizedBox(height: 20),

            // ── Privacy ───────────────────────────────────────────────────────
            _buildLabel('Quyền riêng tư & Dữ liệu'),
            const SizedBox(height: 10),
            _buildCard([
              _buildInfoTile(
                icon: Icons.storage_outlined,
                iconColor: const Color(0xFFF57C00),
                iconBg: const Color(0xFFFFF3E0),
                label: 'Lưu trữ dữ liệu',
                value: 'Cục bộ trên thiết bị',
              ),
              _divider(),
              _buildInfoTile(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFF1976D2),
                iconBg: const Color(0xFFE3F0FF),
                label: 'Bảo mật',
                value: 'Mật khẩu được mã hóa SHA-256',
              ),
              _divider(),
              _buildInfoTile(
                icon: Icons.cloud_off_outlined,
                iconColor: const Color(0xFF00695C),
                iconBg: const Color(0xFFE0F2F1),
                label: 'Kết nối internet',
                value: 'Không yêu cầu',
              ),
            ]),
            const SizedBox(height: 20),

            // ── Developer ─────────────────────────────────────────────────────
            _buildLabel('Nhà phát triển'),
            const SizedBox(height: 10),
            _buildCard([
              _buildInfoTile(
                icon: Icons.person_outline_rounded,
                iconColor: _red,
                iconBg: const Color(0xFFFFEDE8),
                label: 'Phát triển bởi',
                value: 'Tiepnnk',
              ),
              _divider(),
              _buildInfoTile(
                icon: Icons.code_rounded,
                iconColor: const Color(0xFF7B61FF),
                iconBg: const Color(0xFFEDE8FF),
                label: 'Công nghệ',
                value: 'Flutter & Dart',
              ),
            ]),
            const SizedBox(height: 12),

            // ── Footer ────────────────────────────────────────────────────────
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
          ],
        ),
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Về ứng dụng',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      backgroundColor: _red,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  // ─── App Banner ───────────────────────────────────────────────────────────────

  Widget _buildAppBanner() {
    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(72),
            child: Image.asset(
              'assets/images/logo_tet.jpg',
              height: 120,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Quản lý Lời Chúc Tết',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD84315),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v2.0.26',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Label ────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ─── White Card ───────────────────────────────────────────────────────────────

  Widget _buildCard(List<Widget> children) {
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
      child: Column(children: children),
    );
  }

  Widget _divider() =>
      Divider(height: 1, indent: 68, endIndent: 16, color: Colors.grey.shade100);

  // ─── Info Tile ────────────────────────────────────────────────────────────────

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Description Tile ─────────────────────────────────────────────────────────

  Widget _buildDescriptionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
