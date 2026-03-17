import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  // ─── Constants ───────────────────────────────────────────────────────────────
  static const _red = Color(0xFFD32F2F);
  static const _bg = Color(0xFFFCF8F2);

  // Track which FAQ is expanded
  int? _expandedIndex;

  final _faqs = const [
    _FaqItem(
      question: 'Làm thế nào để thêm liên hệ mới?',
      answer:
          'Vào màn hình "Danh bạ", nhấn nút "+" ở góc dưới bên phải để tạo liên hệ mới. Điền đầy đủ thông tin và nhấn "Lưu".',
    ),
    _FaqItem(
      question: 'Làm thế nào để gửi lời chúc Tết?',
      answer:
          'Vào mục "Lời chúc", chọn mẫu lời chúc hoặc tạo lời chúc mới. Sau đó chọn danh sách liên hệ và gửi đi.',
    ),
    _FaqItem(
      question: 'Dữ liệu của tôi có được bảo mật không?',
      answer:
          'Có. Toàn bộ dữ liệu được lưu trữ trực tiếp trên thiết bị của bạn và không được gửi lên bất kỳ máy chủ nào. Mật khẩu được mã hóa SHA-256.',
    ),
    _FaqItem(
      question: 'Tôi có thể nhập danh bạ từ điện thoại không?',
      answer:
          'Có. Sử dụng tính năng "Nhập danh bạ" từ menu chính để đồng bộ liên hệ từ danh bạ điện thoại của bạn.',
    ),
    _FaqItem(
      question: 'Làm thế nào để đổi mật khẩu?',
      answer:
          'Vào Cài đặt → Đổi mật khẩu. Nhập mật khẩu hiện tại và mật khẩu mới. Mật khẩu phải có ít nhất 6 ký tự.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Banner ────────────────────────────────────────────────────────
            _buildBanner(),
            const SizedBox(height: 28),

            // ── Quick Guide ───────────────────────────────────────────────────
            _buildLabel('Hướng dẫn nhanh'),
            const SizedBox(height: 10),
            _buildQuickGuideCard(),
            const SizedBox(height: 20),

            // ── FAQ ───────────────────────────────────────────────────────────
            _buildLabel('Câu hỏi thường gặp'),
            const SizedBox(height: 10),
            ...List.generate(_faqs.length, (i) => _buildFaqTile(i)),
            const SizedBox(height: 20),

            // ── Contact Support ───────────────────────────────────────────────
            _buildLabel('Liên hệ hỗ trợ'),
            const SizedBox(height: 10),
            _buildSupportCard(),
          ],
        ),
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Trợ giúp & Hỗ trợ',
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
            colors: [Color(0xFFEDE8FF), Color(0xFFE3F0FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.support_agent_outlined,
          size: 40,
          color: Color(0xFF7B61FF),
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

  // ─── Quick Guide Card ─────────────────────────────────────────────────────────

  Widget _buildQuickGuideCard() {
    const steps = [
      _GuideStep(
        icon: Icons.person_add_outlined,
        iconColor: Color(0xFFE57373),
        iconBg: Color(0xFFFFEDE8),
        title: 'Thêm liên hệ',
        subtitle: 'Vào Danh bạ → nhấn nút "+"',
      ),
      _GuideStep(
        icon: Icons.card_giftcard_outlined,
        iconColor: Color(0xFF7B61FF),
        iconBg: Color(0xFFEDE8FF),
        title: 'Gửi lời chúc',
        subtitle: 'Vào Lời chúc → chọn mẫu → gửi',
      ),
      _GuideStep(
        icon: Icons.import_contacts_outlined,
        iconColor: Color(0xFF1976D2),
        iconBg: Color(0xFFE3F0FF),
        title: 'Nhập danh bạ',
        subtitle: 'Sử dụng tính năng Nhập danh bạ',
      ),
    ];

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
      child: Column(
        children: steps.asMap().entries.map((e) {
          final step = e.value;
          final isLast = e.key == steps.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: step.iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(step.icon, color: step.iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          step.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 16,
                  color: Colors.grey.shade100,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─── FAQ Tile ─────────────────────────────────────────────────────────────────

  Widget _buildFaqTile(int index) {
    final faq = _faqs[index];
    final isExpanded = _expandedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isExpanded
              ? Border.all(color: const Color(0xFFFFCDD2), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? const Color(0xFFFFEDE8)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'Q',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isExpanded ? _red : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isExpanded
                            ? const Color(0xFFD84315)
                            : const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Container(
                padding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Support Card ─────────────────────────────────────────────────────────────

  Widget _buildSupportCard() {
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
      child: Column(
        children: [
          _buildContactTile(
            icon: Icons.email_outlined,
            iconColor: _red,
            iconBg: const Color(0xFFFFEDE8),
            label: 'Email hỗ trợ',
            value: 'jurgenklopp047@gmail.com',
            onTap: () {
              Clipboard.setData(
                  const ClipboardData(text: 'support@example.com'));
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã sao chép email',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  backgroundColor: const Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),
          Divider(height: 1, indent: 68, endIndent: 16, color: Colors.grey.shade100),
          _buildContactTile(
            icon: Icons.schedule_outlined,
            iconColor: const Color(0xFFF57C00),
            iconBg: const Color(0xFFFFF3E0),
            label: 'Giờ hỗ trợ',
            value: 'Thứ 2 – Thứ 6, 8:00 – 17:00',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (onTap != null)
                Icon(Icons.copy_outlined,
                    color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data Models ────────────────────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

class _GuideStep {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  const _GuideStep({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });
}
