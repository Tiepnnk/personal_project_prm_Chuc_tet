import 'package:flutter/material.dart';
import 'package:personal_project_prm/views/home/home_page.dart';
import 'package:personal_project_prm/views/contacts/contact_page.dart';
import 'package:personal_project_prm/views/wish_template/wish_template_page.dart';
import 'package:personal_project_prm/views/wish/wish_page.dart';
import 'package:personal_project_prm/views/settings/profile_page.dart';

/// Chỉ số tab của Bottom Navigation.
class NavIndex {
  static const int home          = 0;
  static const int contacts      = 1;
  static const int wishTemplates = 2;
  static const int wish      = 3;
  static const int settings      = 4;
}

/// Shared Bottom Navigation Bar dùng chung cho toàn bộ ứng dụng.
///
/// Cách dùng:
/// ```dart
/// bottomNavigationBar: const AppBottomNav(currentIndex: NavIndex.home),
/// ```
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  static const _redTet = Color(0xFFD32F2F);

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return; // đã ở trang này

    Widget destination;
    switch (index) {
      case NavIndex.home:
        destination = const HomePage();
        break;
      case NavIndex.contacts:
        destination = const ContactPage();
        break;
      case NavIndex.wishTemplates:
        destination = const WishTemplatePage();
        break;
      case NavIndex.wish:
        destination = const WishPage();
        break;
      case NavIndex.settings:
        destination = const ProfilePage();
        break;
      default:
        return;
    }

    // Xóa toàn bộ stack và đẩy trang đích → không bị back nhiều lần
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => _onTap(context, i),
      selectedItemColor: _redTet,
      unselectedItemColor: Colors.grey[400],
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      elevation: 16,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contacts_outlined),
          activeIcon: Icon(Icons.contacts),
          label: 'Danh bạ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Lời chúc',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Chúc tết',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
      ],
    );
  }
}
