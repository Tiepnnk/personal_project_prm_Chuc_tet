import 'package:flutter/material.dart';
import 'package:personal_project_prm/viewmodels/contact/contact_viewmodel.dart';

class ContactSearchBar extends StatelessWidget {
  final ContactViewModel viewModel;

  const ContactSearchBar({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          onChanged: (value) {
            viewModel.onSearchChanged(value);
          },
          decoration: InputDecoration(
            hintText: 'Tìm kiếm người thân, bạn bè...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
