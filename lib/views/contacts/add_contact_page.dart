import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_project_prm/di.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';
import 'package:personal_project_prm/viewmodels/contact/add_contact_viewmodel.dart';
import 'package:personal_project_prm/viewmodels/contact/contact_viewmodel.dart';

// ─── Wrapper: cấp AddContactViewModel qua Provider ───────────────────────────

class AddContactPage extends StatelessWidget {
  final bool isEdit;
  final Contact? contactToEdit;

  const AddContactPage({super.key, this.isEdit = false, this.contactToEdit});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddContactViewModel>(
      create: (_) => buildAddContactVM(),
      child: _AddContactView(isEdit: isEdit, contactToEdit: contactToEdit),
    );
  }
}

// ─── View (sử dụng AddContactViewModel) ──────────────────────────────────────

class _AddContactView extends StatefulWidget {
  final bool isEdit;
  final Contact? contactToEdit;
  const _AddContactView({required this.isEdit, this.contactToEdit});

  @override
  State<_AddContactView> createState() => _AddContactViewState();
}

class _AddContactViewState extends State<_AddContactView> {
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();

  // Danh sách loại quan hệ khớp với enum ContactCategory
  final List<_CategoryOption> _categoryOptions = const [
    _CategoryOption(label: 'Gia đình', category: ContactCategory.family),
    _CategoryOption(label: 'Sếp', category: ContactCategory.boss),
    _CategoryOption(label: 'Đồng nghiệp', category: ContactCategory.colleague),
    _CategoryOption(label: 'Đối tác', category: ContactCategory.partner),
    _CategoryOption(label: 'Bạn bè', category: ContactCategory.friend),
    _CategoryOption(label: 'Thầy cô', category: ContactCategory.teacher),
    _CategoryOption(label: 'Hàng xóm', category: ContactCategory.neighbor),
    _CategoryOption(label: 'Khác', category: ContactCategory.other),
  ];

  @override
  void initState() {
    super.initState();
    // Nếu ở Edit Mode, pre-fill data sau khi frame đầu tiên render xong
    if (widget.contactToEdit != null) {
      final contact = widget.contactToEdit!;
      _fullNameController.text = contact.fullName;
      _nicknameController.text = contact.nickname ?? '';
      _phoneController.text = contact.phone;
      _noteController.text = contact.note ?? '';

      // Gọi initForEdit trên ViewModel sau frame đầu tiên
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = Provider.of<AddContactViewModel>(context, listen: false);
        vm.initForEdit(contact);
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ─── Trigger save / update ─────────────────────────────────────────────────

  Future<void> _onSave(AddContactViewModel vm) async {
    if (vm.isEditMode) {
      // Edit mode → gọi updateContact
      await vm.updateContact(
        fullName: _fullNameController.text,
        nickname: _nicknameController.text,
        phone: _phoneController.text,
        note: _noteController.text,
      );
    } else {
      // Add mode → gọi saveContact
      await vm.saveContact(
        fullName: _fullNameController.text,
        nickname: _nicknameController.text,
        phone: _phoneController.text,
        note: _noteController.text,
      );
    }

    if (!mounted) return;

    if (vm.isSaved) {
      // Reload danh sách liên hệ nếu ContactViewModel đang tồn tại
      final contactVM = Provider.of<ContactViewModel>(context, listen: false);
      await contactVM.loadContacts();

      if (!mounted) return;

      final message = vm.isEditMode ? 'Cập nhật thành công!' : 'Thêm liên hệ thành công!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<AddContactViewModel>(
      builder: (context, vm, _) {
        // Nếu có lỗi chung (server / DB) → hiển thị SnackBar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (vm.errorMessage != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(vm.errorMessage!),
                backgroundColor: const Color(0xFFD32F2F),
              ),
            );
          }
        });

        return Scaffold(
          backgroundColor: const Color(0xFFFCFAF5),
          appBar: _buildAppBar(vm.isEditMode),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvatarSection(vm),
                        const SizedBox(height: 32),
                        _buildInputField(
                          label: 'HỌ VÀ TÊN',
                          isRequired: true,
                          hintText: 'Nhập tên đầy đủ...',
                          controller: _fullNameController,
                          errorText: vm.fullNameError,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'BIỆT DANH',
                          hintText: 'Tên thường gọi...',
                          controller: _nicknameController,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'SỐ ĐIỆN THOẠI',
                          isRequired: true,
                          hintText: '090 1234 567',
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          errorText: vm.phoneError,
                        ),
                        const SizedBox(height: 20),
                        _buildCategoryDropdown(vm),
                        const SizedBox(height: 20),
                        _buildPrioritySegmentedControl(vm),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'GHI CHÚ',
                          hintText: 'Thông tin thêm về sở thích, địa chỉ...',
                          maxLines: 4,
                          controller: _noteController,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                _buildSaveButton(vm),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(bool isEditMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        isEditMode ? 'Chỉnh sửa liên hệ' : 'Thêm liên hệ mới',
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      centerTitle: true,
    );
  }

  // ─── Avatar section ────────────────────────────────────────────────────────

  Widget _buildAvatarSection(AddContactViewModel vm) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => vm.pickImage(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE5E7EB),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: vm.avatarPath != null
                        ? Image.file(
                            File(vm.avatarPath!),
                            fit: BoxFit.cover,
                            width: 110,
                            height: 110,
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF9CA3AF),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            vm.avatarPath != null ? 'THAY ĐỔI ẢNH' : 'THÊM ẢNH ĐẠI DIỆN',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input Field ───────────────────────────────────────────────────────────

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFD32F2F)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: errorText != null
                ? Border.all(color: const Color(0xFFD32F2F), width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Category Dropdown ─────────────────────────────────────────────────────

  Widget _buildCategoryDropdown(AddContactViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'LOẠI QUAN HỆ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ContactCategory>(
              value: vm.selectedCategory,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down,
                  color: Colors.grey.shade400),
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              onChanged: (ContactCategory? newValue) {
                if (newValue != null) {
                  vm.onCategoryChanged(newValue);
                }
              },
              items: _categoryOptions
                  .map((opt) => DropdownMenuItem<ContactCategory>(
                        value: opt.category,
                        child: Text(opt.label),
                      ))
                  .toList(),
            ),
          ),
        ),
        if (vm.categoryError != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              vm.categoryError!,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Priority Segmented Control ────────────────────────────────────────────

  Widget _buildPrioritySegmentedControl(AddContactViewModel vm) {
    final priorities = [
      _PriorityOption(
        label: 'Bắt buộc',
        priority: ContactPriority.must,
        activeColor: const Color(0xFFD32F2F),
      ),
      _PriorityOption(
        label: 'Nên gọi',
        priority: ContactPriority.should,
        activeColor: const Color(0xFFFBBF24),
      ),
      _PriorityOption(
        label: 'Tùy chọn',
        priority: ContactPriority.optional,
        activeColor: const Color(0xFF9CA3AF),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'MỨC ĐỘ ƯU TIÊN',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: priorities.map((p) {
              final isSelected = vm.selectedPriority == p.priority;
              return Expanded(
                child: GestureDetector(
                  onTap: () => vm.onPriorityChanged(p.priority),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? p.activeColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p.label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── Save Button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton(AddContactViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: vm.isLoading ? null : () => _onSave(vm),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFECA3A3),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: vm.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  vm.isEditMode ? 'Cập nhật liên hệ' : 'Lưu liên hệ',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}

// ─── Helper data classes ──────────────────────────────────────────────────────

class _CategoryOption {
  final String label;
  final ContactCategory category;
  const _CategoryOption({required this.label, required this.category});
}

class _PriorityOption {
  final String label;
  final ContactPriority priority;
  final Color activeColor;
  const _PriorityOption(
      {required this.label,
      required this.priority,
      required this.activeColor});
}
