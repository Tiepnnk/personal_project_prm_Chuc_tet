import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_project_prm/di.dart';
import 'package:personal_project_prm/domain/entities/wish_template.dart';
import 'package:personal_project_prm/viewmodels/wish_template/create_wish_template_viewmodel.dart';

class CreateWishTemplatePage extends StatelessWidget {
  final WishTemplate? templateToEdit;
  final bool isReadOnly;

  const CreateWishTemplatePage({super.key, this.templateToEdit, this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateWishTemplateViewModel>(
      create: (_) {
        final vm = buildCreateWishTemplateVM();
        if (templateToEdit != null) {
          vm.initForEdit(templateToEdit!);
        }
        return vm;
      },
      child: _CreateWishTemplateView(templateToEdit: templateToEdit, isReadOnly: isReadOnly),
    );
  }
}

class _CreateWishTemplateView extends StatefulWidget {
  final WishTemplate? templateToEdit;
  final bool isReadOnly;

  const _CreateWishTemplateView({this.templateToEdit, this.isReadOnly = false});

  @override
  State<_CreateWishTemplateView> createState() => _CreateWishTemplateViewState();
}

class _CreateWishTemplateViewState extends State<_CreateWishTemplateView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  final int _maxContentLength = 2000;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.templateToEdit?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.templateToEdit?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateWishTemplateViewModel>();

    // Lắng nghe khi lưu thành công → pop
    if (vm.isSaved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context, vm.isEditMode ? 'edited' : 'created');
      });
    }

    // Lắng nghe AI suggestion → điền vào ô content
    if (vm.aiSuggestion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _contentController.text = vm.aiSuggestion!;
        vm.clearAiSuggestion();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
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
                    // 1. Tiêu đề mẫu
                    _buildTitleField(vm),
                    const SizedBox(height: 24),
                    // 2. Chọn nhóm phù hợp
                    _buildGroupSelector(vm),
                    const SizedBox(height: 24),
                    // 3. Nội dung (cùng với nút AI mới)
                    _buildContentField(vm),
                    const SizedBox(height: 24),
                    // 5. Đánh dấu yêu thích
                    _buildFavoriteToggle(vm),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(context, vm),
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
          Text(
            context.read<CreateWishTemplateViewModel>().isEditMode
                ? (widget.isReadOnly ? 'Chi tiết mẫu' : 'Chỉnh sửa mẫu')
                : 'Tạo mẫu mới',
            style: const TextStyle(
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
  Widget _buildTitleField(CreateWishTemplateViewModel vm) {
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
          controller: _titleController,
          enabled: !widget.isReadOnly,
          onChanged: (_) {
            // Clear lỗi tiêu đề khi người dùng bắt đầu gõ
            if (vm.titleError != null) {
              context.read<CreateWishTemplateViewModel>();
            }
          },
          decoration: InputDecoration(
            hintText: 'VD: Lời chúc chân thành cho Sếp',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: vm.titleError != null ? Colors.red : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: vm.titleError != null ? Colors.red : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: vm.titleError != null ? Colors.red : Colors.red.shade300),
            ),
          ),
        ),
        if (vm.titleError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              vm.titleError!,
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // 3. CHỌN NHÓM ĐỐI TƯỢNG
  Widget _buildGroupSelector(CreateWishTemplateViewModel vm) {
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
          children: availableGroups.map((group) {
            final isSelected = vm.selectedGroups.contains(group);
            return GestureDetector(
              onTap: widget.isReadOnly ? null : () => vm.onGroupToggled(group),
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

  // NÚT GỢI Ý AI
  Widget _buildAiSuggestButton(CreateWishTemplateViewModel vm) {
    if (widget.isReadOnly) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: vm.isGeneratingAi
          ? null
          : () => vm.generateAiSuggestion(_titleController.text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: vm.isGeneratingAi
              ? []
              : [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            vm.isGeneratingAi
                ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              vm.isGeneratingAi ? 'Đang tạo...' : 'Gợi ý AI',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. TRƯỜNG NỘI DUNG VÀ CHÈN BIẾN
  Widget _buildContentField(CreateWishTemplateViewModel vm) {
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
            _buildAiSuggestButton(vm),
          ],
        ),
        // Lỗi AI hiển thị ngay dưới dòng tiêu đề nội dung
        if (vm.aiError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    vm.aiError!,
                    style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: vm.contentError != null ? Colors.red : Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _contentController,
                enabled: !widget.isReadOnly,
                maxLines: 8,
                minLines: 5,
                maxLength: _maxContentLength,
                decoration: InputDecoration(
                  hintText: 'Nhập nội dung lời chúc của bạn... Có thể chèn các biến để cá nhân hóa.',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15, height: 1.5),
                  counterText: '', // Ẩn counter mặc định
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              if (vm.contentError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    vm.contentError!,
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                  ),
                ),
              Divider(height: 1, color: Colors.grey.shade200),
              // KHU VỰC CHÈN BIẾN VÀ ĐẾM SỐ KÝ TỰ
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CHÈN BIẾN (Chạm để chèn)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _contentController,
                          builder: (context, value, child) {
                            return Text(
                              '${value.text.length}/$_maxContentLength',
                              style: TextStyle(
                                fontSize: 11, 
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade500
                              ),
                            );
                          },
                        ),
                      ],
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
      onTap: widget.isReadOnly
          ? null
          : () {
              // Chèn placeholder vào vị trí con trỏ trong content field
              final currentText = _contentController.text;
              final selection = _contentController.selection;
              final newText = currentText.replaceRange(
                selection.start < 0 ? currentText.length : selection.start,
                selection.end < 0 ? currentText.length : selection.end,
                placeholder,
              );
              _contentController.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(
                  offset: (selection.start < 0 ? currentText.length : selection.start) + placeholder.length,
                ),
              );
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

  // 6. ĐÁNH DẤU YÊU THÍCH
  Widget _buildFavoriteToggle(CreateWishTemplateViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.isReadOnly ? null : () => vm.onFavoriteToggled(!vm.isFavorite),
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
                  value: vm.isFavorite,
                  onChanged: widget.isReadOnly ? null : (val) => vm.onFavoriteToggled(val),
                  activeThumbColor: Colors.white,
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
  Widget _buildBottomActionBar(BuildContext context, CreateWishTemplateViewModel vm) {
    if (widget.isReadOnly) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              onPressed: vm.isLoading ? null : () => Navigator.pop(context),
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
              onPressed: vm.isLoading
                  ? null
                  : () {
                      vm.saveTemplate(
                        title: _titleController.text,
                        content: _contentController.text,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: vm.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 20),
              label: Text(
                vm.isLoading ? 'Đang lưu...' : 'Lưu template',
                style: const TextStyle(
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
