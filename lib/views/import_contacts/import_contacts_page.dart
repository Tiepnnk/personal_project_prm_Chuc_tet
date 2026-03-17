import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_project_prm/di.dart';
import 'package:personal_project_prm/domain/entities/phone_contact.dart';
import 'package:personal_project_prm/viewmodels/import_contacts/import_contacts_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class ImportContactsPage extends StatelessWidget {
  const ImportContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ImportContactsViewModel>(
      create: (_) {
        final vm = buildImportContactsVM();
        vm.loadPhoneContacts();
        return vm;
      },
      child: const _ImportContactsView(),
    );
  }
}

class _ImportContactsView extends StatelessWidget {
  const _ImportContactsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ImportContactsViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF5),
      appBar: _buildAppBar(context),
      body: _buildBody(context, vm),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final vm = context.read<ImportContactsViewModel>();
    return AppBar(
      backgroundColor: const Color(0xFFFCFAF5),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gán thông tin',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getSubtitle(vm),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF616161),
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F2937), size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  String _getSubtitle(ImportContactsViewModel vm) {
    if (vm.isLoading) return 'Đang đọc danh bạ...';
    final total = vm.newContacts.length + vm.changedContacts.length;
    if (total == 0) return 'Không có liên hệ mới';
    return '$total liên hệ từ danh bạ';
  }

  Widget _buildBody(BuildContext context, ImportContactsViewModel vm) {
    // Loading
    if (vm.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFD32F2F)),
            SizedBox(height: 16),
            Text('Đang đọc danh bạ điện thoại...', style: TextStyle(color: Color(0xFF616161))),
          ],
        ),
      );
    }

    // Permission denied
    if (vm.permissionDenied) {
      return _buildPermissionDeniedView(context);
    }

    // Error
    if (vm.errorMessage != null) {
      return _buildErrorView(vm.errorMessage!, () => vm.loadPhoneContacts());
    }

    // Danh bạ trống
    if (vm.isEmpty) {
      return _buildEmptyView(context, 'Không tìm thấy liên hệ nào trong danh bạ', Icons.contacts_outlined);
    }

    // Tất cả đã tồn tại
    if (vm.allDuplicates) {
      return _buildEmptyView(context, 'Tất cả liên hệ đã được thêm trước đó', Icons.check_circle_outline);
    }

    // Main content
    return Column(
      children: [
        _buildLegendRow(),
        Expanded(
          child: _ContactListView(vm: vm),
        ),
        _buildBottomBar(context, vm),
      ],
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_accounts_rounded, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              'Cần quyền truy cập danh bạ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
            ),
            const SizedBox(height: 12),
            Text(
              'Ứng dụng cần được phép đọc danh bạ để tìm và import liên hệ từ điện thoại của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openAppSettings(),
              icon: const Icon(Icons.settings, size: 20),
              label: const Text('Mở cài đặt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại', style: TextStyle(color: Color(0xFF616161))),
            ),
          ],
        ),
      ),
    );
  }

  void _openAppSettings() async {
    // Mở Settings
    final uri = Uri.parse('app-settings:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildErrorView(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF9E9E9E)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Quay lại', style: TextStyle(color: Color(0xFF424242))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Bắt buộc', const Color(0xFFD32F2F)),
          _buildLegendItem('Nên gọi', const Color(0xFFFFA000)),
          _buildLegendItem('Tùy chọn', const Color(0xFF757575)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ImportContactsViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: vm.isImporting ? null : () => _onImport(context, vm),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: vm.isImporting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      'Import ${vm.totalImportCount - 1} liên hệ (${vm.assignedCount}/${vm.newContacts.length} đã gán)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Gán sau trong màn hình quản lý',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Icon(Icons.arrow_downward, size: 14, color: Color(0xFF616161)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onImport(BuildContext context, ImportContactsViewModel vm) async {
    final countSnapshot = vm.totalImportCount; // Lưu lại trước khi import
    final success = await vm.importContacts();
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import $countSnapshot liên hệ thành công!'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context, true);
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage!),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DANH SÁCH LIÊN HỆ (New + Changed)
// ═══════════════════════════════════════════════════════════════════════════════

class _ContactListView extends StatelessWidget {
  final ImportContactsViewModel vm;
  const _ContactListView({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFCFAF5),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 8),
        itemCount: vm.newContacts.length + (vm.changedContacts.isNotEmpty ? vm.changedContacts.length + 1 : 0),
        itemBuilder: (context, index) {
          // Section: Liên hệ mới
          if (index < vm.newContacts.length) {
            return _NewContactCard(
              contact: vm.newContacts[index],
              index: index,
              vm: vm,
            );
          }

          // Divider tiêu đề "Liên hệ có thay đổi"
          final changedIndex = index - vm.newContacts.length;
          if (changedIndex == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '⚠️ Có thay đổi (${vm.changedContacts.length})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                    ),
                  ),
                ],
              ),
            );
          }

          // Liên hệ nhóm thay đổi
          final ci = changedIndex - 1;
          return _ChangedContactCard(
            contact: vm.changedContacts[ci],
            index: ci,
            isSelected: vm.changedSelection[ci],
            onToggle: () => vm.toggleChangedSelection(ci),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARD LIÊN HỆ MỚI (với dropdowns)
// ═══════════════════════════════════════════════════════════════════════════════

class _NewContactCard extends StatelessWidget {
  final PhoneContact contact;
  final int index;
  final ImportContactsViewModel vm;

  const _NewContactCard({required this.contact, required this.index, required this.vm});

  // Avatar colors cycle — dùng tông ấm phù hợp theme
  static const _avatarColors = [
    Color(0xFFFFCDD2), // Light Red
    Color(0xFFFFF9C4), // Light Yellow
    Color(0xFFC8E6C9), // Light Green
    Color(0xFFFFE0B2), // Light Orange
    Color(0xFFE1BEE7), // Light Purple
  ];

  // Relationship options — khớp với ContactCategory enum trong DB
  static const _relationships = [
    {'label': 'Gia đình',     'value': 'FAMILY'},
    {'label': 'Sếp',          'value': 'BOSS'},
    {'label': 'Đồng nghiệp',  'value': 'COLLEAGUE'},
    {'label': 'Đối tác',      'value': 'PARTNER'},
    {'label': 'Bạn bè',       'value': 'FRIEND'},
    {'label': 'Thầy cô',      'value': 'TEACHER'},
    {'label': 'Hàng xóm',     'value': 'NEIGHBOR'},
    {'label': 'Khác',         'value': 'OTHER'},
  ];

  // Level options
  static const _levels = [
    {'label': 'Bắt buộc', 'value': 'MUST',     'color': 0xFFD32F2F},
    {'label': 'Nên gọi',  'value': 'SHOULD',   'color': 0xFFFFA000},
    {'label': 'Tùy chọn', 'value': 'OPTIONAL', 'color': 0xFF757575},
  ];

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColors[index % _avatarColors.length];
    final initials = _getInitials(contact.displayName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header row: avatar + name + phone + X button
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarColor,
                child: Text(
                  initials,
                  style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                    const SizedBox(height: 2),
                    Text(contact.rawPhone, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, color: Color(0xFFD32F2F), size: 16),
                  tooltip: 'Bỏ qua liên hệ này',
                  onPressed: () => vm.removeNewContact(index),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dropdowns
          Row(
            children: [
              Expanded(child: _buildRelationshipDropdown(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildLevelDropdown(context)),
            ],
          ),
          const SizedBox(height: 12),
          // Nickname
          _buildNicknameField(context),
        ],
      ),
    );
  }

  Widget _buildRelationshipDropdown(BuildContext context) {
    final hasValue = contact.relationship != null && contact.relationship!.isNotEmpty;
    // Tìm label hiện tại
    String displayLabel = 'Quan hệ';
    if (hasValue) {
      final match = _relationships.where((r) => r['value'] == contact.relationship).toList();
      if (match.isNotEmpty) {
        displayLabel = match.first['label']!;
      }
    }

    return GestureDetector(
      onTap: () => _showRelationshipPicker(context),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: hasValue ? const Color(0xFFFEE2E2) : const Color(0xFFF9FAFB),
          border: Border.all(color: hasValue ? const Color(0xFFD32F2F) : const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayLabel,
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: hasValue ? const Color(0xFFD32F2F) : const Color(0xFF6B7280),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18, color: hasValue ? const Color(0xFFD32F2F) : const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  void _showRelationshipPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Chọn quan hệ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              ..._relationships.map((r) => ListTile(
                title: Text(r['label']!),
                trailing: contact.relationship == r['value'] ? const Icon(Icons.check, color: Color(0xFFD32F2F)) : null,
                onTap: () {
                  vm.updateRelationship(index, r['value']);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelDropdown(BuildContext context) {
    final hasValue = contact.contactLevel != null && contact.contactLevel!.isNotEmpty;
    String displayLabel = 'Mức độ';
    Color dotColor = Colors.transparent;

    if (hasValue) {
      final match = _levels.where((l) => l['value'] == contact.contactLevel).toList();
      if (match.isNotEmpty) {
        displayLabel = match.first['label'] as String;
        dotColor = Color(match.first['color'] as int);
      }
    }

    return GestureDetector(
      onTap: () => _showLevelPicker(context),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: hasValue ? dotColor.withOpacity(0.08) : const Color(0xFFF9FAFB),
          border: Border.all(color: hasValue ? dotColor : const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (hasValue) ...[
              Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                displayLabel,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: hasValue ? const Color(0xFF1F2937) : const Color(0xFF6B7280)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18, color: hasValue ? const Color(0xFF1F2937) : const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  void _showLevelPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Chọn mức độ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ..._levels.map((l) {
              final color = Color(l['color'] as int);
              return ListTile(
                leading: Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                title: Text(l['label'] as String),
                trailing: contact.contactLevel == l['value'] ? const Icon(Icons.check, color: Color(0xFFD32F2F)) : null,
                onTap: () {
                  vm.updateContactLevel(index, l['value'] as String);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNicknameField(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: TextEditingController(text: contact.nickname ?? ''),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
        onChanged: (value) => vm.updateNickname(index, value),
        decoration: const InputDecoration(
          hintText: 'Biệt danh (tùy chọn)',
          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15, fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARD LIÊN HỆ THAY ĐỔI (checkbox chọn update)
// ═══════════════════════════════════════════════════════════════════════════════

class _ChangedContactCard extends StatelessWidget {
  final PhoneContact contact;
  final int index;
  final bool isSelected;
  final VoidCallback onToggle;

  const _ChangedContactCard({
    required this.contact,
    required this.index,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFFFFB74D) : Colors.transparent),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (_) => onToggle(),
            activeColor: const Color(0xFFFF9800),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.displayName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.rawPhone,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF616161)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tên trong danh bạ khác với tên trong app',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
