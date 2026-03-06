import 'package:flutter/material.dart';
import 'package:personal_project_prm/viewmodels/contact/contact_viewmodel.dart';
import 'package:provider/provider.dart';

class ContactCategoryFilter extends StatelessWidget {
  const ContactCategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Consumer<ContactViewModel>(
        builder: (context, viewModel, child) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: viewModel.categories.length,
            itemBuilder: (context, index) {
              final category = viewModel.categories[index];
              final isSelected = category == viewModel.selectedCategory;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    viewModel.onCategorySelected(category);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
