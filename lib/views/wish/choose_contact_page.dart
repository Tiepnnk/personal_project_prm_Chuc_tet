import 'dart:io';

import 'package:flutter/material.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';
import 'package:personal_project_prm/viewmodels/wish/wish_viewmodel.dart';
import 'package:provider/provider.dart';

class ChooseContactPage extends StatefulWidget {
  const ChooseContactPage({super.key});

  /// Hàm tiện ích để hiển thị trang chọn người liên lạc dưới dạng BottomSheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChooseContactPage(),
    );
  }

  @override
  State<ChooseContactPage> createState() => _ChooseContactPageState();
}

class _ChooseContactPageState extends State<ChooseContactPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<WishViewModel>(context, listen: false);
      vm.loadPendingContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.9;

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
          // 1. Kéo / Header
          _buildDragHandle(),
          _buildHeader(context),

          // 2. Tìm kiếm và Lọc
          _buildSearchBar(),
          _buildFilterChips(),
          const Divider(height: 1, color: Color(0xFFEEEEEE), thickness: 1),

          // 3. Danh sách
          Expanded(child: _buildContactList()),

          // 4. Nút xác nhận
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chọn người nhận',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEFF3F8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, size: 20, color: Color(0xFF546E7A)),
              onPressed: () {
                // Nhấn X → xóa lựa chọn đã chọn và đóng sheet
                Provider.of<WishViewModel>(context, listen: false)
                    .deselectContact();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          Provider.of<WishViewModel>(context, listen: false)
              .setContactSearch(val);
        },
        decoration: InputDecoration(
          hintText: 'Tìm tên, biệt danh, số ĐT...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD32F2F)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<WishViewModel>(
      builder: (context, vm, _) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Row(
          children: [
            _buildFilterChip(vm, 'Tất cả',
                isSelected: vm.contactPriorityFilter == 'Tất cả'),
            const SizedBox(width: 8),
            _buildFilterChip(vm, 'Bắt buộc',
                dotColor: const Color(0xFFE53935),
                isSelected: vm.contactPriorityFilter == 'Bắt buộc'),
            const SizedBox(width: 8),
            _buildFilterChip(vm, 'Nên gọi',
                dotColor: const Color(0xFFFF9800),
                isSelected: vm.contactPriorityFilter == 'Nên gọi'),
            const SizedBox(width: 8),
            _buildFilterChip(vm, 'Tùy chọn',
                dotColor: const Color(0xFFB0BEC5),
                isSelected: vm.contactPriorityFilter == 'Tùy chọn'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    WishViewModel vm,
    String label, {
    Color? dotColor,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => vm.setContactFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD32F2F)
                : const Color(0xFFFFE0B2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (dotColor ?? const Color(0xFFD32F2F)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList() {
    return Consumer<WishViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoadingContacts) {
          return const Center(child: CircularProgressIndicator());
        }
        final contacts = vm.displayedContacts;
        if (contacts.isEmpty) {
          return Center(
            child: Text(
              'Không có liên lạc nào cần gọi.',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: contacts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _buildContactCard(contacts[index], vm),
        );
      },
    );
  }

  Widget _buildContactCard(Contact contact, WishViewModel vm) {
    final bool isSelected = vm.selectedContact?.id == contact.id;
    final priorityColor = _priorityColor(contact.priority);
    final relationshipInfo = _relationshipInfo(contact.category);

    return GestureDetector(
      onTap: () => vm.selectContact(contact),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF2F2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFCDD2) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar — hiển thị ảnh nếu có, ngược lại hiển thị chữ cái đầu
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: contact.avatar != null && contact.avatar!.isNotEmpty
                        ? Image.file(
                            File(contact.avatar!),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                contact.fullName.isNotEmpty
                                    ? contact.fullName[0].toUpperCase()
                                    : 'A',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD32F2F),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              contact.fullName.isNotEmpty
                                  ? contact.fullName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          contact.fullName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: relationshipInfo['bgColor'] as Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          relationshipInfo['label'] as String,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: relationshipInfo['textColor'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        contact.nickname ?? contact.fullName,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.circle,
                            size: 4, color: Colors.grey.shade400),
                      ),
                      Expanded(
                        child: Text(
                          contact.phone,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Radio / Check
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFFD32F2F)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD32F2F)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 14, color: Colors.white))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Contact đã được lưu trong vm.selectedContact khi tap card
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            'Xác nhận chọn',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Color _priorityColor(ContactPriority priority) {
    switch (priority) {
      case ContactPriority.must:
        return const Color(0xFFE53935);
      case ContactPriority.should:
        return const Color(0xFFFF9800);
      case ContactPriority.optional:
        return const Color(0xFFB0BEC5);
    }
  }

  Map<String, dynamic> _relationshipInfo(ContactCategory category) {
    switch (category) {
      case ContactCategory.family:
        return {
          'label': 'GIA ĐÌNH',
          'bgColor': const Color(0xFFE8F5E9),
          'textColor': const Color(0xFF2E7D32),
        };
      case ContactCategory.boss:
        return {
          'label': 'SẾP',
          'bgColor': const Color(0xFFE8EAF6),
          'textColor': const Color(0xFF3949AB),
        };
      case ContactCategory.colleague:
        return {
          'label': 'ĐỒNG NGHIỆP',
          'bgColor': const Color(0xFFE8F5E9),
          'textColor': const Color(0xFF2E7D32),
        };
      case ContactCategory.partner:
        return {
          'label': 'ĐỐI TÁC',
          'bgColor': const Color(0xFFE3F2FD),
          'textColor': const Color(0xFF1976D2),
        };
      case ContactCategory.friend:
        return {
          'label': 'BẠN BÈ',
          'bgColor': const Color(0xFFF3E5F5),
          'textColor': const Color(0xFF8E24AA),
        };
      case ContactCategory.teacher:
        return {
          'label': 'THẦY CÔ',
          'bgColor': const Color(0xFFFFF3E0),
          'textColor': const Color(0xFFE65100),
        };
      case ContactCategory.neighbor:
        return {
          'label': 'HÀNG XÓM',
          'bgColor': const Color(0xFFF1F8E9),
          'textColor': const Color(0xFF558B2F),
        };
      case ContactCategory.other:
        return {
          'label': 'KHÁC',
          'bgColor': const Color(0xFFF5F5F5),
          'textColor': const Color(0xFF757575),
        };
    }
  }
}
