import 'package:flutter/material.dart';
import 'package:personal_project_prm/viewmodels/register/register_viewmodel.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  _RegisterPageState() {
    _userCtrl.addListener(_clearError);
    _passCtrl.addListener(_clearError);
    _confirmPassCtrl.addListener(_clearError);
    _fullNameCtrl.addListener(_clearError);
    _phoneCtrl.addListener(_clearError);
  }

  void _clearError() {
    final vm = context.read<RegisterViewModel>();
    vm.clearError();
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<RegisterViewModel>();
    final success = await vm.register(
      userName: _userCtrl.text,
      password: _passCtrl.text,
      confirmPassword: _confirmPassCtrl.text,
      fullName: _fullNameCtrl.text,
      phone: _phoneCtrl.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Quay về trang đăng nhập
    }
  }

  @override
  Widget build(BuildContext context) {
    const redTet = Color(0xFFD32F2F);

    final vm = context.watch<RegisterViewModel>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          image: DecorationImage(
            image: const AssetImage('assets/images/bg_tet.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.1), // Phủ sáng mờ tương tự trang login
              BlendMode.lighten,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Tiêu đề form
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: redTet,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: redTet.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: const Icon(Icons.person_add_alt_1, size: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: redTet.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Đăng Ký Tài Khoản',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: redTet,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          
                          _buildTextField(
                            controller: _userCtrl,
                            label: 'Tên đăng nhập *',
                            hint: 'Nhập tên đăng nhập',
                            icon: Icons.person_outline,
                            redTet: redTet,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildPasswordField(
                            controller: _passCtrl,
                            label: 'Mật khẩu *',
                            hint: 'Nhập mật khẩu',
                            icon: Icons.lock_outline,
                            redTet: redTet,
                            obscureText: _obscurePassword,
                            onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                            validator: (v) {
                               if (v == null || v.trim().isEmpty) return 'Bắt buộc nhập';
                               if (v.trim().length < 6) return 'Tối thiểu 6 ký tự';
                               return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          _buildPasswordField(
                            controller: _confirmPassCtrl,
                            label: 'Nhập lại mật khẩu *',
                            hint: 'Xác nhận lại mật khẩu',
                            icon: Icons.lock_reset,
                            redTet: redTet,
                            obscureText: _obscureConfirmPassword,
                            onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            validator: (v) {
                               if (v == null || v.trim().isEmpty) return 'Bắt buộc nhập';
                               if (v.trim() != _passCtrl.text.trim()) return 'Mật khẩu không khớp';
                               return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _fullNameCtrl,
                            label: 'Họ và Tên *',
                            hint: 'Tên hiển thị',
                            icon: Icons.badge_outlined,
                            redTet: redTet,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _phoneCtrl,
                            label: 'Số điện thoại',
                            hint: 'Tùy chọn',
                            icon: Icons.phone_android,
                            redTet: redTet,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                               if (v == null || v.trim().isEmpty) return null;
                               final phone = v.trim();
                               if (!RegExp(r'^[0-9]+$').hasMatch(phone)) return 'Chỉ được nhập số';
                               if (!phone.startsWith('0')) return 'Số điện thoại phải bắt đầu bằng số 0';
                               if (phone.length != 10) return 'Số điện thoại phải có đúng 10 số';
                               return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          if (vm.error != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      vm.error!,
                                      style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          _buildActionBtn(vm, redTet),
                          const SizedBox(height: 20),
                          _buildBackLink(redTet),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color redTet,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: redTet),
        filled: true,
        fillColor: const Color(0xFFFFF8E1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: redTet.withValues(alpha: 0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: redTet.withValues(alpha: 0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: redTet, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color redTet,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: redTet),
        suffixIcon: IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: redTet), onPressed: onToggle),
        filled: true,
        fillColor: const Color(0xFFFFF8E1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: redTet.withValues(alpha: 0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: redTet.withValues(alpha: 0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: redTet, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildActionBtn(RegisterViewModel vm, Color redTet) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: redTet.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: vm.isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: vm.isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person_add, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text('Đăng Ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
      ),
    );
  }

  Widget _buildBackLink(Color redTet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Đã có tài khoản? ', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text('Đăng nhập ngay', style: TextStyle(fontSize: 14, color: redTet, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}
