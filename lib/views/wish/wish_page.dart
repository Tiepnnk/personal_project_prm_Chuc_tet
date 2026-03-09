import 'package:flutter/material.dart';
import 'package:personal_project_prm/views/widgets/app_bottom_nav.dart';
import 'package:personal_project_prm/views/wish/choose_contact_page.dart';
/// Màn hình Gọi Chúc Tết
class WishPage extends StatelessWidget {
  const WishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF7EB), // Nền màu vàng nhạt gần giống ảnh
      body: _WishView(),
      bottomNavigationBar: AppBottomNav(currentIndex: NavIndex.wish),
    );
  }
}

class _WishView extends StatelessWidget {
  const _WishView();

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
                // 1. Người liên lạc
                const _SectionTitle(title: '1. Người liên lạc'),
                const SizedBox(height: 12),
                _buildContactSelection(context),
                
                const SizedBox(height: 24),
                
                // 2. Mẫu lời chúc
                const _SectionTitle(title: '2. Mẫu lời chúc (Không bắt buộc)'),
                const SizedBox(height: 12),
                _buildTemplateSelection(context),
                
                const SizedBox(height: 24),
                
                // 3. Nội dung lời chúc
                const _SectionTitle(title: '3. Nội dung lời chúc'),
                const SizedBox(height: 12),
                _buildContentInput(),
              ],
            ),
          ),
        ),
        _buildBottomActions(context),
      ],
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFFD32F2F), // Màu đỏ chủ đạo
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 16),
      child: Row(
        children: [
          const SizedBox(width: 48), // Padding left cho cân xứng
          const Expanded(
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
          const SizedBox(width: 48), // Spacer để cân bằng IconButton
        ],
      ),
    );
  }

  // 1. CONTACT SELECTION
  Widget _buildContactSelection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ChooseContactPage.show(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF3F8), // Màu nền circle icon người nhận
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Color(0xFF78909C)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                color: Color(0xFFFFEBEE), // Màu nền icon kính lúp
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Color(0xFFD32F2F), size: 20), // Icon kính lúp đỏ
            ),
          ],
        ),
      ),
    );
  }

  // 2. TEMPLATE SELECTION
  Widget _buildTemplateSelection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E1), // Màu nền vàng nhạt cho icon
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFFFFB300)), // Icon lấp lánh vàng
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
    );
  }

  // 3. CONTENT INPUT
  Widget _buildContentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              const TextField(
                maxLines: 8,
                minLines: 5,
                decoration: InputDecoration(
                  hintText: 'Viết lời chúc Tết chân thành của bạn tại đây, hoặc chọn một mẫu lời chúc ở trên...',
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
                    color: Color(0xFFF5F7F9), // Màu xám nhạt icon mic
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: Color(0xFF546E7A)), // Icon mic
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Nội dung này sẽ được hiển thị khi bạn gọi video chúc Tết.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  // BOTTOM ACTIONS
  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
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
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              ),
              icon: const Icon(Icons.send, size: 20),
              label: const Text(
                'Gửi lời chúc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.phone, size: 20),
              label: const Text(
                'Gọi chúc Tết',
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold, // Chữ đậm đỏ cho tiêu đề phần
        color: Color(0xFFD32F2F), 
      ),
    );
  }
}
