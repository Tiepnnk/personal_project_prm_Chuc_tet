import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_project_prm/views/contacts/add_contact_page.dart';
import 'package:personal_project_prm/viewmodels/contact/contact_viewmodel.dart';
import 'package:personal_project_prm/domain/entities/contact.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_app_bar.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_search_bar.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_category_filter.dart';
import 'package:personal_project_prm/views/contacts/widgets/contact_card.dart';
import 'package:personal_project_prm/views/widgets/app_bottom_nav.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late ContactViewModel _viewModel;
  // Lưu reference tới ScaffoldMessenger root để tránh mất SnackBar khi rebuild
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ContactViewModel>(context, listen: false);
    // Tự động load toàn bộ danh sách danh bạ từ database
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF5), // Nhẹ nhàng, ấm áp
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

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: viewModel.filteredContacts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == viewModel.filteredContacts.length) {
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
                      
                      final contact = viewModel.filteredContacts[index];
                      return ContactCard(
                        contact: contact,
                        wishStatus: viewModel.getWishStatus(contact.id),
                        onEdit: () => _onEditContact(contact),
                        onDelete: () => _onDeleteContact(contact),
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
                      );
                    },
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
              color: Colors.red.withOpacity(0.3),
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
      // Chờ xóa xong rồi mới hiện SnackBar
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
