import 'package:flutter/material.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';
import 'package:personal_project_prm/domain/entities/wish_template.dart';
import 'package:personal_project_prm/viewmodels/wish/wish_viewmodel.dart';
import 'package:personal_project_prm/views/wish/view_detail_wish_template_page.dart';
import 'package:provider/provider.dart';

class ChooseWishTemplatePage extends StatefulWidget {
  const ChooseWishTemplatePage({super.key});

  /// Hàm tiện ích để hiển thị trang chọn mẫu lời chúc dưới dạng BottomSheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChooseWishTemplatePage(),
    );
  }

  @override
  State<ChooseWishTemplatePage> createState() => _ChooseWishTemplatePageState();
}

class _ChooseWishTemplatePageState extends State<ChooseWishTemplatePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<WishViewModel>(context, listen: false);
      vm.loadTemplates();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.9;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),

          // Tìm kiếm và Gợi ý
          _buildSearchBar(),
          _buildFilterChips(),

          // Danh sách mẫu
          Expanded(child: _buildTemplateList()),

          // Nút xác nhận
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Chọn mẫu lời chúc',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEFF3F8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.close, size: 20, color: Color(0xFF546E7A)),
              onPressed: () {
                // Nhấn X → xóa lựa chọn đã chọn và đóng sheet
                Provider.of<WishViewModel>(context, listen: false)
                    .deselectTemplate();
                Navigator.pop(context);
              },
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          Provider.of<WishViewModel>(context, listen: false)
              .setTemplateSearch(val);
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tựa đề lời chúc...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
    return Consumer<WishViewModel>(
      builder: (context, vm, _) {
        final contact = vm.selectedContact;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                'Gợi ý theo:',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.family_restroom,
                      size: 14,
                      color: Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      contact != null
                          ? contact.category.displayName
                          : 'Tất cả',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateList() {
    return Consumer<WishViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoadingTemplates) {
          return const Center(child: CircularProgressIndicator());
        }
        final templates = vm.displayedTemplates;
        if (templates.isEmpty) {
          return Center(
            child: Text(
              'Không có mẫu lời chúc phù hợp.',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: templates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) =>
              _buildTemplateCard(templates[index], vm),
        );
      },
    );
  }

  Widget _buildTemplateCard(WishTemplate template, WishViewModel vm) {
    final bool isSelected = vm.selectedTemplate?.id == template.id;
    // Chuyển từ DB format (FAMILY, BOSS...) sang tiếng Việt (Gia đình, Sếp...)
    final tagLabel = template.targetGroups.isNotEmpty
        ? template.targetGroups
            .map((g) => ContactCategoryExtension.fromDbString(g).displayName)
            .join(', ')
        : 'Chung';

    return GestureDetector(
      onTap: () => vm.selectTemplate(template),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade200,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng 1: Tiêu đề và Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    template.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC3545),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tagLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dòng 2: Nội dung tóm tắt
            Text(
              template.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Dòng 3: Các nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Nút xem chi tiết (Eye icon)
                    GestureDetector(
                      onTap: () {
                        ViewDetailWishTemplatePage.show(context, template);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF3F8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.visibility,
                          size: 18,
                          color: Color(0xFF546E7A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Icon tym (Yêu thích)
                    GestureDetector(
                      onTap: () =>
                          vm.toggleFavoriteTemplate(template.id, template.isFavorite),
                      child: Icon(
                        template.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: template.isFavorite
                            ? const Color(0xFFD32F2F)
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Lượt sử dụng
                    Text(
                      '${template.usageCount}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Nút chọn
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFFD32F2F)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD32F2F)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(Icons.check, size: 18, color: Colors.white),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Template đã được chọn vào vm.selectedTemplate khi tap card
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Xác nhận mẫu đã chọn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 20, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
