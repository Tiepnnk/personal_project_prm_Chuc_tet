import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';
import 'package:personal_project_prm/viewmodels/home/home_viewmodel.dart';
import 'package:personal_project_prm/viewmodels/wish/wish_viewmodel.dart';
import 'package:personal_project_prm/views/wish/wish_page.dart';

class PrioritySection extends StatefulWidget {
  const PrioritySection({super.key});

  @override
  State<PrioritySection> createState() => _PrioritySectionState();
}

class _PrioritySectionState extends State<PrioritySection> {
  List<Contact> _items = [];
  List<Contact> _fullList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final vm = context.read<HomeViewModel>();
      final all = await vm.contactRepository.getAll();
      final year = DateTime.now().year;
      final statusMap = await vm.wishRecordRepository.getStatusMapForYear(year);

      final filtered = all.where((c) {
        final status = statusMap[c.id];
        final isPending = status == null || status == WishStatus.pending;
        return c.priority == ContactPriority.must && isPending;
      }).toList();

      _fullList = filtered;
      _items = filtered.take(5).toList();
    } catch (e) {
      debugPrint('Error loading priority contacts: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAll() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBF5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // ── Header ───────────────────────────────────────────
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Ưu tiên hôm nay',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_fullList.length} người',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFD32F2F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ── Danh sách ────────────────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: _fullList.length,
                      itemBuilder: (_, i) => _buildPriorityCard(_fullList[i]),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _avatar(Contact c) {
    if (c.avatar != null && c.avatar!.isNotEmpty) {
      if (c.avatar!.startsWith('http')) {
        return CircleAvatar(radius: 26, backgroundImage: NetworkImage(c.avatar!));
      }
      return CircleAvatar(radius: 26, backgroundImage: FileImage(File(c.avatar!)));
    }
    // No avatar: show initials with a pleasant colored border
    // Use first character of fullName for avatar initials
    final initials = c.fullName.trim().isNotEmpty
      ? c.fullName.characters.take(1).toString().toUpperCase()
      : '?';

    Color _colorFor(String key) {
      final palette = [
        Colors.pink.shade200,
        Colors.orange.shade200,
        Colors.blue.shade200,
        Colors.green.shade200,
        Colors.purple.shade200,
        Colors.teal.shade200,
      ];
      final idx = key.hashCode.abs() % palette.length;
      return palette[idx];
    }

    final borderColor = _colorFor(c.id);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2.2),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildPriorityCard(Contact c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          _avatar(c),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and nickname on the same line as "Name - nickname"
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: c.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (c.nickname != null && c.nickname!.isNotEmpty)
                      TextSpan(text: ' - ${c.nickname}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 8),
                // Badge placed above phone number
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: const Text('BẮT BUỘC', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                // Phone number (badge is above this)
                Text(c.phone, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              // Pre-select contact in WishViewModel rồi navigate sang trang Gọi Chúc Tết
              final wishVm = context.read<WishViewModel>();
              wishVm.selectContact(c);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WishPage()),
              );
            },
            child: Container(
              height: 44,
              width: 44,
              decoration: const BoxDecoration(color: Color(0xFF1FC377), shape: BoxShape.circle),
              child: const Icon(Icons.phone, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            const Text('Ưu tiên hôm nay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E1E1E))),
            const Spacer(),
            TextButton(
              onPressed: _fullList.isNotEmpty ? _showAll : null,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading) const Center(child: SizedBox(height: 36, width: 36, child: CircularProgressIndicator())) else ...[
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text('Không có liên hệ bắt buộc chưa gọi', style: TextStyle(color: Colors.grey[600])),
            )
          else
            for (final c in _items) _buildPriorityCard(c),
        ],
      ],
    );
  }
}
