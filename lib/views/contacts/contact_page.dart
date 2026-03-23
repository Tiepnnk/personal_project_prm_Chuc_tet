import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_project_prm/views/contacts/add_contact_page.dart';
import 'package:personal_project_prm/viewmodels/contact/contact_viewmodel.dart';
import 'package:personal_project_prm/viewmodels/wish/wish_viewmodel.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_app_bar.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_search_bar.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_category_filter.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_card.dart';
import 'package:personal_project_prm/views/widgets/app_bottom_nav.dart';
import 'package:personal_project_prm/views/wish/wish_page.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late ContactViewModel _viewModel;
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ContactViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadContacts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF5),
      body: SafeArea(
        child: Column(
          children: [
            ContactAppBar(
              onAddPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddContactPage()),
                ).then((result) async {
                  if (result == true && mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thêm liên hệ thành công!'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  }
                  await _viewModel.loadContacts();
                });
              },
            ),
            ContactSearchBar(viewModel: _viewModel),
            const ContactCategoryFilter(),
            Expanded(
              child: Consumer<ContactViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.filteredContacts.isEmpty) {
                    return const Center(
                      child: Text(
                        'Hiện chưa có nội dung',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    );
                  }

                  final grouped = viewModel.groupedContacts;
                  final letters = viewModel.availableLetters;

                  // Xây danh sách item: header + contact cards + footer
                  final List<Widget> listItems = [];
                  for (final letter in letters) {
                    final contacts = grouped[letter]!;
                    listItems.add(_buildLetterHeader(letter));
                    for (final contact in contacts) {
                      listItems.add(_buildContactItem(contact, viewModel));
                    }
                  }
                  listItems.add(_buildFooter());

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: listItems,
                  );
                },

              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddContactPage()),
            ).then((result) async {
              if (result == true && mounted) {
                _scaffoldMessenger.clearSnackBars();
                _scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Thêm liên hệ thành công!'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              }
              await _viewModel.loadContacts();
            });
          },
          backgroundColor: const Color(0xFFD32F2F),
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const AppBottomNav(currentIndex: NavIndex.contacts),
    );
  }

  // ── Letter Header ──────────────────────────────────────────────────────────

  Widget _buildLetterHeader(String letter) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: Colors.grey.shade200,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Contact Card Item ──────────────────────────────────────────────────────

  Widget _buildContactItem(Contact contact, ContactViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ContactCard(
        contact: contact,
        wishStatus: viewModel.getWishStatus(contact.id),
        onEdit: () => _onEditContact(contact),
        onDelete: () => _onDeleteContact(contact),
        onCall: () => _onCallContact(contact),
        isSelectionMode: viewModel.isSelectionMode,
        isSelected: viewModel.selectedContactIds.contains(contact.id),
        onLongPress: () {
          if (!viewModel.isSelectionMode) {
            viewModel.toggleSelectionMode();
            viewModel.toggleSelectContact(contact.id);
          }
        },
        onSelect: () {
          viewModel.toggleSelectContact(contact.id);
        },
      ),
    );
  }

  // ── Gọi điện → Chuyển sang trang Chúc Tết ──────────────────────────────────

  void _onCallContact(Contact contact) {
    // Pre-select contact vào WishViewModel (có SĐT + tên)
    final wishVm = Provider.of<WishViewModel>(context, listen: false);
    wishVm.selectContact(contact);

    // Navigate sang trang Chúc Tết (xóa stack giống AppBottomNav)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WishPage()),
      (route) => false,
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      child: Center(
        child: Text(
          '🌸 Phiên bản 2.0.26 (Tết Bính Ngọ) 🌸',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ─── Chỉnh sửa liên hệ ────────────────────────────────────────────────────

  void _onEditContact(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactPage(
          isEdit: true,
          contactToEdit: contact,
        ),
      ),
    ).then((result) async {
      if (result == true && mounted) {
        _scaffoldMessenger.clearSnackBars();
        _scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Chỉnh sửa liên hệ thành công!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
      await _viewModel.loadContacts();
    });
  }

  // ─── Xóa liên hệ (với confirm dialog) ────────────────────────────────────

  Future<void> _onDeleteContact(Contact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Xóa liên hệ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          'Bạn chắc chắn muốn xóa liên hệ\n"${contact.fullName}" không?',
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Text('Hủy',
                style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Xóa',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _viewModel.deleteContact(contact.id);
      if (mounted) {
        _scaffoldMessenger.clearSnackBars();
        if (_viewModel.errorMessage == null) {
          _scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Xóa thành công'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        } else {
          _scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(_viewModel.errorMessage!),
              backgroundColor: const Color(0xFFD32F2F),
            ),
          );
        }
      }
    }
  }
}

// ─── Alphabet Side Bar Widget ─────────────────────────────────────────────────

class _AlphabetSideBar extends StatefulWidget {
  final List<String> letters;
  final void Function(String letter) onLetterTap;

  const _AlphabetSideBar({
    required this.letters,
    required this.onLetterTap,
  });

  @override
  State<_AlphabetSideBar> createState() => _AlphabetSideBarState();
}

class _AlphabetSideBarState extends State<_AlphabetSideBar> {
  String? _activeLetter;

  // Map chữ cái -> letter bằng vị trí y tương đối trong side bar
  String _letterFromLocalY(double localY, double totalHeight) {
    if (widget.letters.isEmpty) return '';
    final itemH = totalHeight / widget.letters.length;
    final index = (localY / itemH).floor().clamp(0, widget.letters.length - 1);
    return widget.letters[index];
  }

  void _handleTouch(Offset globalPos) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localY = box.globalToLocal(globalPos).dy.clamp(0.0, box.size.height);
    final letter = _letterFromLocalY(localY, box.size.height);
    if (letter.isEmpty || letter == _activeLetter) return;
    setState(() => _activeLetter = letter);
    widget.onLetterTap(letter);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.letters.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _handleTouch(d.globalPosition),
      onTapUp: (_) => Future.delayed(
        const Duration(milliseconds: 350),
        () { if (mounted) setState(() => _activeLetter = null); },
      ),
      onVerticalDragStart: (d) => _handleTouch(d.globalPosition),
      onVerticalDragUpdate: (d) => _handleTouch(d.globalPosition),
      onVerticalDragEnd: (_) => setState(() => _activeLetter = null),
      child: Container(
        width: 28,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 6,
              offset: const Offset(-1, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.letters.map((letter) {
            final isActive = letter == _activeLetter;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 24,
              height: 24,
              margin: const EdgeInsets.symmetric(vertical: 1),
              decoration: isActive
                  ? const BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    )
                  : null,
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? Colors.white : const Color(0xFFD32F2F),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
