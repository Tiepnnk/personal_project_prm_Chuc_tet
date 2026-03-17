import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_project_prm/viewmodels/profile/profile_viewmodel.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  // ─── Constants ───────────────────────────────────────────────────────────────
  static const _red = Color(0xFFD32F2F);
  static const _bg = Color(0xFFFCF8F2);

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final vm = context.read<ProfileViewModel>();
    final ok = await vm.changePassword(
      _currentCtrl.text.trim(),
      _newCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Đổi mật khẩu thành công ✓', success: true),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar(vm.errorMessage ?? 'Đổi mật khẩu thất bại', success: false),
      );
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
              // ── Icon Banner ──────────────────────────────────────────────────
              _buildBanner(),
              const SizedBox(height: 28),

              // ── Password Fields ──────────────────────────────────────────────
              _buildLabel('Mật khẩu hiện tại'),
              const SizedBox(height: 10),
              _buildCard([
                _buildPasswordField(
                  icon: Icons.lock_open_outlined,
                  iconColor: const Color(0xFFE57373),
                  iconBg: const Color(0xFFFFEDE8),
                  label: 'Mật khẩu hiện tại',
                  controller: _currentCtrl,
                  obscure: !_showCurrent,
                  onToggle: () => setState(() => _showCurrent = !_showCurrent),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Vui lòng nhập mật khẩu hiện tại'
                      : null,
                ),
              ]),
              const SizedBox(height: 20),

              _buildLabel('Mật khẩu mới'),
              const SizedBox(height: 10),
              _buildCard([
                _buildPasswordField(
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFF1976D2),
                  iconBg: const Color(0xFFE3F0FF),
                  label: 'Mật khẩu mới',
                  controller: _newCtrl,
                  obscure: !_showNew,
                  onToggle: () => setState(() => _showNew = !_showNew),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                    if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                    return null;
                  },
                ),
                _divider(),
                _buildPasswordField(
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFF1976D2),
                  iconBg: const Color(0xFFE3F0FF),
                  label: 'Nhập lại mật khẩu mới',
                  controller: _confirmCtrl,
                  obscure: !_showConfirm,
                  onToggle: () => setState(() => _showConfirm = !_showConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập lại mật khẩu mới';
                    if (v != _newCtrl.text) return 'Mật khẩu không khớp';
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 12),

              // ── Hint ─────────────────────────────────────────────────────────
              _buildHint(),
              const SizedBox(height: 32),

              // ── Submit Button ─────────────────────────────────────────────────
              _buildSubmitButton(),
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
        'Đổi mật khẩu',
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

  // ─── Banner ───────────────────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFEDE8), Color(0xFFFFF3E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.shield_outlined,
          size: 38,
          color: _red,
        ),
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

  // ─── Password Field Row ───────────────────────────────────────────────────────

  Widget _buildPasswordField({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
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
              obscureText: obscure,
              validator: validator,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                labelText: label,
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
                suffixIcon: GestureDetector(
                  onTap: onToggle,
                  child: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hint Text ────────────────────────────────────────────────────────────────

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFF9A825), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mật khẩu phải có ít nhất 6 ký tự. Không chia sẻ mật khẩu với người khác.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Submit Button ────────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Material(
      color: _loading ? Colors.grey.shade300 : _red,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: _loading ? null : _submit,
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
                  'Xác nhận đổi mật khẩu',
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
