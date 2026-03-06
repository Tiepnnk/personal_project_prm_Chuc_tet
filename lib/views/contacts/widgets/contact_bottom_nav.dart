import 'package:flutter/material.dart';
import 'package:personal_project_prm/views/home/home_page.dart';
import 'package:personal_project_prm/views/settings/profile_page.dart';

class ContactBottomNav extends StatelessWidget {
  const ContactBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildNavItem(context, Icons.home_filled, 'Trang chủ', false, () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            }),
            _buildNavItem(context, Icons.contacts, 'Danh bạ', true, () {}),
            const SizedBox(width: 48), // Khoảng trống cho FAB
            _buildNavItem(context, Icons.pie_chart, 'Tiến độ', false, () {}),
            _buildNavItem(context, Icons.settings, 'Cài đặt', false, () {
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

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
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
