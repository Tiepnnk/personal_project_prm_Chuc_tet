import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_project_prm/viewmodels/profile/profile_viewmodel.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  // ─── Constants ───────────────────────────────────────────────────────────────
  static const _red = Color(0xFFD32F2F);
  static const _bg = Color(0xFFFCF8F2);
  static const _cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    final vm = context.read<ProfileViewModel>();
    final user = vm.currentUser;
    _nameCtrl.text = user?.fullName ?? '';
    _phoneCtrl.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final vm = context.read<ProfileViewModel>();
    await vm.updateProfile(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (mounted) {
      if (vm.errorMessage == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Cập nhật thông tin thành công ✓', success: true),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar(vm.errorMessage!, success: false),
        );
      }
    }
  }

  SnackBar _snackBar(String msg, {required bool success}) {
    return SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: success ? const Color(0xFF4CAF50) : _red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final user = vm.currentUser;

    final displayName = (user?.fullName?.isNotEmpty == true)
        ? user!.fullName!
        : (user?.userName ?? 'Người dùng');
    final avatarPath = user?.avatar;
    final initials = displayName.trim().isNotEmpty
        ? displayName.trim().split(' ').length >= 2
            ? '${displayName.trim().split(' ').first[0]}${displayName.trim().split(' ').last[0]}'
                .toUpperCase()
            : displayName.trim()[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── AVATAR ───────────────────────────────────────────────────────
              _buildAvatarSection(avatarPath, initials, user?.userName),
              const SizedBox(height: 28),

              // ── INFO CARD ─────────────────────────────────────────────────────
              _buildLabel('Thông tin hiển thị'),
              const SizedBox(height: 10),
              _buildCard([
                _buildField(
                  icon: Icons.person_outline_rounded,
                  iconColor: _red,
                  iconBg: const Color(0xFFFFEDE8),
                  label: 'Họ và tên',
                  controller: _nameCtrl,
                  hint: 'Nhập họ và tên',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Vui lòng nhập họ và tên' : null,
                ),
                _divider(),
                _buildField(
                  icon: Icons.phone_outlined,
                  iconColor: const Color(0xFF1976D2),
                  iconBg: const Color(0xFFE3F0FF),
                  label: 'Số điện thoại',
                  controller: _phoneCtrl,
                  hint: 'Nhập số điện thoại',
                  keyboardType: TextInputType.phone,
                ),
              ]),
              const SizedBox(height: 16),

              // ── READ-ONLY CARD ────────────────────────────────────────────────
              _buildLabel('Thông tin tài khoản'),
              const SizedBox(height: 10),
              _buildCard([
                _buildReadOnlyTile(
                  icon: Icons.alternate_email_rounded,
                  iconColor: const Color(0xFF7B61FF),
                  iconBg: const Color(0xFFEDE8FF),
                  label: 'Tên đăng nhập',
                  value: user?.userName ?? '—',
                ),
              ]),
              const SizedBox(height: 32),

              // ── SAVE BUTTON ───────────────────────────────────────────────────
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Thông tin cá nhân',
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

  // ─── Avatar Section ───────────────────────────────────────────────────────────

  Widget _buildAvatarSection(
      String? avatarPath, String initials, String? userName) {
    final resolvedPath = avatarPath ?? '';
    final hasAvatar =
        resolvedPath.isNotEmpty && File(resolvedPath).existsSync();

    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8C99A), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: const Color(0xFFFFF3E0),
              backgroundImage: hasAvatar ? FileImage(File(resolvedPath)) : null,
              child: !hasAvatar
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _red,
                      ),
                    )
                  : null,
            ),
          ),
          if (userName != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDE8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '@$userName',
                style: const TextStyle(
                  fontSize: 13,
                  color: _red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
        color: _cardBg,
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

  Widget _divider() => Divider(height: 1, indent: 68, endIndent: 16, color: Colors.grey.shade100);

  // ─── Editable Field Row ───────────────────────────────────────────────────────

  Widget _buildField({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
                floatingLabelStyle: TextStyle(
                  fontSize: 12,
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                ),
                errorStyle: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Read-Only Tile ───────────────────────────────────────────────────────────

  Widget _buildReadOnlyTile({
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
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Không thể sửa',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Save Button ──────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Material(
      color: _loading ? Colors.grey.shade300 : _red,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: _loading ? null : _save,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Lưu thay đổi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}
