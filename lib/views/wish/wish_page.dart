import 'package:flutter/material.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';
import 'package:personal_project_prm/viewmodels/wish/wish_viewmodel.dart';
import 'package:personal_project_prm/views/widgets/app_bottom_nav.dart';
import 'package:personal_project_prm/views/wish/choose_contact_page.dart';
import 'package:personal_project_prm/views/wish/choose_wish_template_page.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// Màn hình Gọi Chúc Tết
class WishPage extends StatelessWidget {
  const WishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF7EB),
      body: _WishView(),
      bottomNavigationBar: AppBottomNav(currentIndex: NavIndex.wish),
    );
  }
}

class _WishView extends StatefulWidget {
  const _WishView();

  @override
  State<_WishView> createState() => _WishViewState();
}

class _WishViewState extends State<_WishView> {
  bool _showContactError = false;
  bool _showContentError = false;

  @override
  void initState() {
    super.initState();
    // Tự động xoá lỗi nội dung khi người dùng bắt đầu nhập
    final vm = Provider.of<WishViewModel>(
      // ignore: use_build_context_synchronously
      context,
      listen: false,
    );
    vm.contentController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (_showContentError &&
        Provider.of<WishViewModel>(context, listen: false)
            .contentController
            .text
            .trim()
            .isNotEmpty) {
      setState(() => _showContentError = false);
    }
  }

  @override
  void dispose() {
    final vm = Provider.of<WishViewModel>(context, listen: false);
    vm.contentController.removeListener(_onContentChanged);
    super.dispose();
  }

  /// Kiểm tra hợp lệ. Trả về true nếu thoả điều kiện.
  bool _validate(WishViewModel vm) {
    final hasContact = vm.selectedContact != null;
    final hasContent = vm.contentController.text.trim().isNotEmpty;
    setState(() {
      _showContactError = !hasContact;
      _showContentError = !hasContent;
    });
    return hasContact && hasContent;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Người liên lạc *
                const _SectionTitle(title: '1. Người liên lạc', required: true),
                const SizedBox(height: 12),
                _buildContactSelection(context),
                if (_showContactError) _buildErrorText('Yêu cầu chọn người liên lạc'),

                const SizedBox(height: 24),

                // 2. Mẫu lời chúc
                const _SectionTitle(title: '2. Mẫu lời chúc (Không bắt buộc)'),
                const SizedBox(height: 12),
                _buildTemplateSelection(context),

                const SizedBox(height: 24),

                // 3. Nội dung lời chúc *
                _buildContentInput(context),
                if (_showContentError) _buildErrorText('Nội dung không được để trống'),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    '🌸 Phiên bản 2.0.26 (Tết Bính Ngọ) 🌸',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _buildBottomActions(context),
      ],
    );
  }

  Widget _buildErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: Color(0xFFD32F2F)),
          const SizedBox(width: 6),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFD32F2F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFFD32F2F),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        16,
      ),
      child: const Row(
        children: [
          SizedBox(width: 48),
          Expanded(
            child: Center(
              child: Text(
                'Gọi Chúc Tết',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  // 1. CONTACT SELECTION
  Widget _buildContactSelection(BuildContext context) {
    return Consumer<WishViewModel>(
      builder: (context, vm, _) {
        final contact = vm.selectedContact;
        // Auto-xoá lỗi khi đã chọn contact
        if (contact != null && _showContactError) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => setState(() => _showContactError = false),
          );
        }
        return GestureDetector(
          onTap: () async {
            await ChooseContactPage.show(context);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: contact != null
                  ? Border.all(color: const Color(0xFFFFCDD2), width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: contact != null
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFEFF3F8),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: contact != null
                        ? Text(
                            contact.fullName.isNotEmpty
                                ? contact.fullName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD32F2F),
                            ),
                          )
                        : const Icon(Icons.person, color: Color(0xFF78909C)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: contact != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${contact.phone}  •  ${contact.category.displayName}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chọn người nhận',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Từ danh bạ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Color(0xFFD32F2F),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. TEMPLATE SELECTION
  Widget _buildTemplateSelection(BuildContext context) {
    return Consumer<WishViewModel>(
      builder: (context, vm, _) {
        final template = vm.selectedTemplate;
        return GestureDetector(
          onTap: () async {
            await ChooseWishTemplatePage.show(context);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: template != null
                  ? Border.all(color: const Color(0xFFFFCDD2), width: 1.5)
                  : Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFFFFB300)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: template != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              template.targetGroups.isNotEmpty
                                  ? template.targetGroups
                                      .map((g) => ContactCategoryExtension.fromDbString(g).displayName)
                                      .join(', ')
                                  : 'Chung',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chọn mẫu lời chúc',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gợi ý từ AI hoặc Yêu thích',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. CONTENT INPUT
  Widget _buildContentInput(BuildContext context) {
    return Consumer<WishViewModel>(
      builder: (context, vm, _) {
        final hasContact = vm.selectedContact != null;

        // Hiển thị lỗi AI nếu có
        if (vm.aiError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(vm.aiError!),
                  backgroundColor: const Color(0xFFD32F2F),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng Title và Nút Gợi ý AI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: _SectionTitle(title: '3. Nội dung lời chúc', required: true),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 38,
                      child: ElevatedButton.icon(
                        onPressed: (hasContact && !vm.isGeneratingAi)
                            ? () => vm.generateAiWishContent()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade200,
                          disabledForegroundColor: Colors.grey.shade400,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        icon: vm.isGeneratingAi
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 16),
                        label: Text(
                          vm.isGeneratingAi ? 'Đang tạo...' : '✨ Gợi ý AI',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (!hasContact)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Vui lòng chọn người\nliên lạc để sử dụng AI',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                            height: 1.2,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: vm.contentController,
                    maxLines: 8,
                    minLines: 5,
                    decoration: const InputDecoration(
                      hintText:
                          'Viết lời chúc Tết chân thành của bạn tại đây, hoặc chọn một mẫu lời chúc ở trên...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 15,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F7F9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // BOTTOM ACTIONS
  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              onPressed: () => _onSendWish(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              ),
              icon: const Icon(Icons.send, size: 20),
              label: const Text(
                'Gửi lời chúc',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: () => _onCallWish(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.phone, size: 20),
              label: const Text(
                'Gọi chúc Tết',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onCallWish(BuildContext context) async {
    final vm = Provider.of<WishViewModel>(context, listen: false);
    if (!_validate(vm)) return;

    final called = await vm.callContact();
    if (!called) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở ứng dụng gọi điện.')),
        );
      }
      return;
    }

    if (context.mounted) {
      _showCallResultSheet(context, vm);
    }
  }

  void _showCallResultSheet(BuildContext context, WishViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Kết quả cuộc gọi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuộc gọi đến ${vm.selectedContact?.fullName ?? ''} đã kết thúc.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await vm.markAsCalled();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Đã gọi (thành công)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await vm.markAsNotAnswered();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF546E7A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'Chưa nghe máy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSendWish(BuildContext context) async {
    final vm = Provider.of<WishViewModel>(context, listen: false);
    if (!_validate(vm)) return;
    _showSendSheet(context, vm);
  }

  void _showSendSheet(BuildContext context, WishViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gửi lời chúc qua',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSendOption(
              ctx,
              icon: Icons.sms,
              label: 'Tin nhắn SMS',
              color: const Color(0xFF1976D2),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await vm.sendViaSms();
                if (ok && context.mounted) {
                  _showMarkMessagedDialog(context, vm);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildSendOption(
              ctx,
              icon: Icons.share,
              label: 'Chia sẻ khác...',
              color: const Color(0xFF546E7A),
              onTap: () async {
                Navigator.pop(ctx);
                final content = vm.contentController.text.trim();
                if (content.isNotEmpty) {
                  await Share.share(content);
                  if (context.mounted) {
                    _showMarkMessagedDialog(context, vm);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _showMarkMessagedDialog(BuildContext context, WishViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận'),
        content: Text(
          'Bạn đã gửi lời chúc đến ${vm.selectedContact?.fullName ?? ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Chưa', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await vm.markAsMessaged();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đã gửi'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool required;

  const _SectionTitle({required this.title, this.required = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFFD32F2F),
        ),
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Color(0xFFD32F2F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}
