import 'package:flutter/material.dart';

class ChooseContactPage extends StatefulWidget {
  const ChooseContactPage({super.key});

  /// Hàm tiện ích để hiển thị trang chọn người liên lạc dưới dạng BottomSheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChooseContactPage(),
    );
  }

  @override
  State<ChooseContactPage> createState() => _ChooseContactPageState();
}

class _ChooseContactPageState extends State<ChooseContactPage> {
  // Trạng thái (UI only)
  String _selectedPriority = 'Tất cả';
  int _selectedContactId = 2; // Giả lập chọn Nguyễn Thị Mai

  // Dữ liệu giả lập (Mock data)
  final List<Map<String, dynamic>> _mockContacts = [
    {
      'id': 1,
      'name': 'Trần Văn Hùng',
      'nickname': 'Anh Hùng',
      'phone': '090 123 4567',
      'relationship': 'SẾP',
      'relationshipColor': const Color(0xFFE8EAF6),
      'relationshipTextColor': const Color(0xFF3949AB),
      'priority': 'MUST',
      'priorityColor': const Color(0xFFE53935),
      'avatarColor': const Color(0xFFFFEBEE),
      'avatarText': 'H',
      'avatarTextColor': const Color(0xFFD32F2F),
    },
    {
      'id': 2,
      'name': 'Nguyễn Thị Mai',
      'nickname': 'Chị Mai',
      'phone': '098 765 4321',
      'relationship': 'ĐỐI TÁC',
      'relationshipColor': const Color(0xFFE3F2FD),
      'relationshipTextColor': const Color(0xFF1976D2),
      'priority': 'MUST',
      'priorityColor': const Color(0xFFE53935),
      'avatarColor': const Color(0xFFE64A19),
      'avatarText': 'M',
      'avatarTextColor': Colors.white,
    },
    {
      'id': 3,
      'name': 'Lê Thanh Tùng',
      'nickname': 'Tùng IT',
      'phone': '091 234 5678',
      'relationship': 'ĐỒNG NGHIỆP',
      'relationshipColor': const Color(0xFFE8F5E9),
      'relationshipTextColor': const Color(0xFF2E7D32),
      'priority': 'SHOULD',
      'priorityColor': const Color(0xFFFF9800),
      'avatarColor': const Color(0xFFFFF3E0),
      'avatarText': 'T',
      'avatarTextColor': const Color(0xFFE65100),
    },
    {
      'id': 4,
      'name': 'Phạm Hoa',
      'nickname': 'Hoa Béo',
      'phone': '097 654 3210',
      'relationship': 'BẠN BÈ',
      'relationshipColor': const Color(0xFFF3E5F5),
      'relationshipTextColor': const Color(0xFF8E24AA),
      'priority': 'OPTION',
      'priorityColor': const Color(0xFFB0BEC5),
      'avatarColor': const Color(0xFFF0F4C3),
      'avatarText': 'H',
      'avatarTextColor': const Color(0xFF558B2F),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Chiều cao bottom sheet khoảng 90% màn hình
    final height = MediaQuery.of(context).size.height * 0.9;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF5), // Nền trắng ngà
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 1. Kéo / Header
          _buildDragHandle(),
          _buildHeader(context),

          // 2. Tìm kiếm và Lọc
          _buildSearchBar(),
          _buildFilterChips(),
          const Divider(height: 1, color: Color(0xFFEEEEEE), thickness: 1),

          // 3. Danh sách
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _mockContacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final contact = _mockContacts[index];
                return _buildContactCard(contact);
              },
            ),
          ),

          // 4. Nút xác nhận
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chọn người nhận',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEFF3F8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, size: 20, color: Color(0xFF546E7A)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm tên, biệt danh, số ĐT...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD32F2F)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          _buildFilterChip('Tất cả', isSelected: _selectedPriority == 'Tất cả'),
          const SizedBox(width: 8),
          _buildFilterChip('MUST', dotColor: const Color(0xFFE53935), isSelected: _selectedPriority == 'MUST'),
          const SizedBox(width: 8),
          _buildFilterChip('SHOULD', dotColor: const Color(0xFFFF9800), isSelected: _selectedPriority == 'SHOULD'),
          const SizedBox(width: 8),
          _buildFilterChip('OPTION', dotColor: const Color(0xFFB0BEC5), isSelected: _selectedPriority == 'OPTION'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {Color? dotColor, required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFD32F2F) : const Color(0xFFFFE0B2), // Viền cam nhạt cho chi không chọn
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (dotColor ?? const Color(0xFFD32F2F)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    final bool isSelected = _selectedContactId == contact['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedContactId = contact['id'];
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF2F2) : Colors.white, // Nền hồng nhạt khi chọn
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFCDD2) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: contact['avatarColor'],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      contact['avatarText'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: contact['avatarTextColor'],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: contact['priorityColor'],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        contact['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Relationship Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: contact['relationshipColor'],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          contact['relationship'],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: contact['relationshipTextColor'],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        contact['nickname'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.circle, size: 4, color: Colors.grey.shade400),
                      ),
                      Text(
                        contact['phone'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Radio / Check
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFD32F2F) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(child: Icon(Icons.check, size: 14, color: Colors.white))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // TODO: Trả về contact được chọn
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            'Xác nhận chọn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
