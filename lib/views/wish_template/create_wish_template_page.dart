import 'package:flutter/material.dart';

class CreateWishTemplatePage extends StatefulWidget {
  const CreateWishTemplatePage({super.key});

  @override
  State<CreateWishTemplatePage> createState() => _CreateWishTemplatePageState();
}

class _CreateWishTemplatePageState extends State<CreateWishTemplatePage> {
  // Biến trạng thái UI
  bool _showTitleError = false; // Demo validate
  final int _maxContentLength = 500;
  int _currentContentLength = 0;
  
  // Dữ liệu mock
  final List<String> _groups = ['Gia đình', 'Bạn bè', 'Đồng nghiệp', 'Sếp', 'Đối tác'];
  final Set<String> _selectedGroups = {'Gia đình'};
  bool _isFavorite = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Màu be nhạt nền Tết
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleField(),
                    const SizedBox(height: 24),
                    _buildContentField(),
                    const SizedBox(height: 32),
                    _buildGroupSelector(),
                    const SizedBox(height: 24),
                    _buildFavoriteToggle(),
                    const SizedBox(height: 24), // padding bottom
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  // 1. HEADER
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1A1A1A)),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Tạo mẫu mới',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  // 2. TRƯỜNG TIÊU ĐỀ
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Tiêu đề mẫu ',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
            ),
            Text(
              '*',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red.shade700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: (text) {
            // Demo logic tắt/bật validate lỗi
            setState(() {
              _showTitleError = text.isEmpty;
            });
          },
          decoration: InputDecoration(
            hintText: 'VD: Lời chúc chân thành cho Sếp',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _showTitleError ? Colors.red : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _showTitleError ? Colors.red : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _showTitleError ? Colors.red : Colors.red.shade300),
            ),
          ),
        ),
        if (_showTitleError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Tiêu đề không được để trống',
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // 3 & 4. TRƯỜNG NỘI DUNG VÀ CHÈN BIẾN
  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Nội dung ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                ),
                Text(
                  '*',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                ),
              ],
            ),
            Text(
              '$_currentContentLength/$_maxContentLength ký tự',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                maxLines: 8,
                minLines: 5,
                maxLength: _maxContentLength,
                onChanged: (text) {
                  setState(() => _currentContentLength = text.length);
                },
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung lời chúc của bạn... Có thể chèn các biến để cá nhân hóa.',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15, height: 1.5),
                  counterText: '', // Ẩn counter mặc định của TextField vì đã làm custom
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              // KHU VỰC CHÈN BIẾN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHÈN BIẾN (Chạm để chèn)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildVariableChip('{{ten}}', 'Tên'),
                        _buildVariableChip('{{nam_am}}', 'Bính Ngọ'),
                        _buildVariableChip('{{nam_duong}}', '2026'),
                        _buildVariableChip('{{quan_he}}', 'Xưng hô'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVariableChip(String placeholder, String description) {
    return InkWell(
      onTap: () {
        // Handle insert variable logic here in future
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              placeholder,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. CHỌN NHÓM ĐỐI TƯỢNG
  Widget _buildGroupSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phù hợp cho nhóm',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _groups.map((group) {
            final isSelected = _selectedGroups.contains(group);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedGroups.remove(group);
                  } else {
                    _selectedGroups.add(group);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      group,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 6. ĐÁNH DẤU YÊU THÍCH
  Widget _buildFavoriteToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFFD32F2F),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đánh dấu yêu thích',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hiển thị ưu tiên trong danh sách',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isFavorite,
                  onChanged: (val) {
                    setState(() {
                      _isFavorite = val;
                    });
                  },
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFFD32F2F),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 7. FOOTER BUTTON
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), // padding bottom cho an toàn
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
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle save template
                // Demo validate check
                setState(() {
                  _showTitleError = false; // reset
                });
                Navigator.pop(context); // Demo thành công
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: const Icon(Icons.save_outlined, size: 20),
              label: const Text(
                'Lưu template',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
