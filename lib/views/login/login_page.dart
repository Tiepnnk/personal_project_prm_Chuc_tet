import 'package:flutter/material.dart';
import 'package:personal_project_prm/viewmodels/login/login_viewmodel.dart';
import 'package:personal_project_prm/views/home/home_page.dart';
import 'package:personal_project_prm/views/register/register_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _loginError;

  _LoginPageState() {
    // Xóa lỗi khi người dùng bắt đầu nhập
    _userCtrl.addListener(_clearError);
    _passCtrl.addListener(_clearError);
  }

  void _clearError() {
    if (_loginError != null) {
      setState(() {
        _loginError = null;
      });
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // Xử lý đăng nhập
  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<LoginViewModel>();
    final success = await vm.login(_userCtrl.text, _passCtrl.text);

    if (success && mounted) {
      // Đăng nhập thành công - chuyển sang màn hình chính
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (mounted) {
      // Đăng nhập thất bại - hiển thị lỗi dưới trường nhập mật khẩu
      setState(() {
        _loginError = 'Bạn đã nhập sai tài khoản hoặc mật khẩu';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Màu sắc Tết truyền thống
    const redTet = Color(0xFFD32F2F); // Đỏ Tết
    const yellowTet = Color(0xFFFF8F00); // Vàng Tết
    const warmBackground = Color(0xFFFFF8E1); // Nền ấm
    const darkRed = Color(0xFFB71C1C); // Đỏ đậm

    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      // Nền trang trí Tết
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1), // Màu nền dự phòng
          image: DecorationImage(
            image: const AssetImage('assets/images/bg_tet.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0), // Phủ một lớp sáng mờ nhẹ để form hiển thị rõ (nếu cần)
              BlendMode.lighten,
            ),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(redTet, yellowTet, darkRed),
                    const SizedBox(height: 30),
                    _buildLogoIllustration(),
                    const SizedBox(height: 24),
                    _buildLoginForm(redTet, yellowTet, warmBackground, vm),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Header với Tiêu đề
  Widget _buildHeader(Color redTet, Color yellowTet, Color darkRed) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Chủ đề Xuân Bính Ngọ - Tết 2026
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8F00), Color(0xFFFFB300)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: yellowTet.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Xuân Bính Ngọ – Tết 2026',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Widget Logo
  Widget _buildLogoIllustration() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.18),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo_tet.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                'Chưa có logo_tet.jpg\n(Vui lòng lưu ảnh vào thư mục assets/images)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget Form đăng nhập
  Widget _buildLoginForm(Color redTet, Color yellowTet, Color warmBackground, LoginViewModel vm) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: redTet.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tiêu đề form
          Text(
            'Đăng Nhập',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: redTet,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Trường Tên đăng nhập
          _buildTextField(
            controller: _userCtrl,
            label: 'Tên đăng nhập',
            hint: 'Nhập tên đăng nhập',
            icon: Icons.person_outline,
            redTet: redTet,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên đăng nhập';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Trường Mật khẩu
          _buildPasswordField(
            controller: _passCtrl,
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu',
            icon: Icons.lock_outline,
            redTet: redTet,
            obscurePassword: _obscurePassword,
            onToggleVisibility: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              return null;
            },
          ),
          // Hiển thị lỗi đăng nhập
          if (_loginError != null) ...[
            const SizedBox(height: 8),
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
                      _loginError!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Link Quên mật khẩu
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng đang được phát triển!'),
                    backgroundColor: Color(0xFFFF8F00),
                  ),
                );
              },
              child: Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  color: redTet,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Nút Đăng nhập
          _buildLoginButton(vm, redTet, yellowTet),
          const SizedBox(height: 20),

          // Dòng "Chưa có tài khoản? Đăng ký ngay"
          _buildRegisterLink(redTet),
        ],
      ),
    );
  }

  // Widget TextField thường
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color redTet,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: redTet),
        filled: true,
        fillColor: const Color(0xFFFFF8E1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: redTet.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: redTet.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: redTet, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  // Widget TextField mật khẩu có icon ẩn/hiện
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color redTet,
    required bool obscurePassword,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscurePassword,
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: redTet),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: redTet,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: const Color(0xFFFFF8E1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: redTet.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: redTet.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: redTet, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  // Widget Nút Đăng nhập
  Widget _buildLoginButton(
    LoginViewModel vm,
    Color redTet,
    Color yellowTet,
  ) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: redTet.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: vm.isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
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
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Đăng Nhập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Widget link đăng ký
  Widget _buildRegisterLink(Color redTet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            );
          },
          child: Text(
            'Đăng ký ngay',
            style: TextStyle(
              fontSize: 14,
              color: redTet,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
