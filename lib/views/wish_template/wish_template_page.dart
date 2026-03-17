import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:personal_project_prm/di.dart';
import 'package:personal_project_prm/domain/entities/wish_template.dart';
import 'package:personal_project_prm/viewmodels/wish_template/wish_template_viewmodel.dart';
import 'package:personal_project_prm/views/widgets/app_bottom_nav.dart';
import 'package:personal_project_prm/views/wish_template/create_wish_template_page.dart';
import 'package:personal_project_prm/domain/entities/wish_enums.dart';

// ─────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────

const _redTet = Color(0xFFD32F2F);
const _yellowFav = Color(0xFFFFB300);
const _bgScreen = Color(0xFFFFF8F0);
const _bgChipSelected = _redTet;
const _bgChipUnselected = Color(0xFFEEEEEE);
const _textChipUnselected = Color(0xFF616161);
const _bgSystemBadge = Color(0xFFE3F2FD);
const _textSystemBadge = Color(0xFF1565C0);
const _bgGroupChip = Color(0xFFF0F0F0);

const _categories = [
  'Tất cả',
  'Gia đình',
  'Bạn bè',
  'Sếp',
  'Đồng nghiệp',
  'Đối tác',
  'Thầy cô',
  'Khác',
];

// ─────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────

class WishTemplatePage extends StatelessWidget {
  const WishTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WishTemplateViewModel>(
      create: (_) => buildWishTemplateVM()..loadTemplates(),
      child: const _WishTemplateView(),
    );
  }
}

class _WishTemplateView extends StatefulWidget {
  const _WishTemplateView();

  @override
  State<_WishTemplateView> createState() => _WishTemplateViewState();
}

class _WishTemplateViewState extends State<_WishTemplateView> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  late ScaffoldMessengerState _scaffoldMessenger;
  // Selection mode for bulk delete
  bool _selectionMode = false;
  final Set<String> _selectedTemplateIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WishTemplateViewModel>();

    return Scaffold(
      backgroundColor: _bgScreen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _selectionMode
              ? _SelectionHeader(
                  selectedCount: _selectedTemplateIds.length,
                  onCancel: () {
                    setState(() {
                      _selectionMode = false;
                      _selectedTemplateIds.clear();
                    });
                  },
                  onDelete: () async {
                    await _showDeleteDialog(context).then((confirm) async {
                      if (confirm == true) {
                        for (final id in List<String>.from(_selectedTemplateIds)) {
                          await vm.deleteTemplate(id);
                        }
                        if (mounted) {
                          setState(() {
                            _selectionMode = false;
                            _selectedTemplateIds.clear();
                          });
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Xóa các mẫu đã chọn thành công!'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        }
                        await vm.loadTemplates();
                      }
                    });
                  },
                  onSelectAll: () {
                    setState(() {
                      _selectionMode = true;
                      _selectedTemplateIds.clear();
                      _selectedTemplateIds.addAll(vm.filteredTemplates.where((t) => !t.isSystem).map((t) => t.id));
                    });
                  },
                )
              : _WishHeader(
                  isSearchActive: _isSearchActive,
                  searchController: _searchController,
                  onSearchToggle: () {
                    setState(() {
                      _isSearchActive = !_isSearchActive;
                      if (!_isSearchActive) {
                        _searchController.clear();
                        vm.onSearchChanged('');
                      }
                    });
                  },
                  onSearchChanged: vm.onSearchChanged,
                  onFilterTap: () => _showFilterBottomSheet(context, vm),
                ),
          _CategoryFilter(
            categories: _categories,
            selectedIndex: vm.selectedCategoryIndex,
            onSelected: (i) => vm.onCategorySelected(i),
          ),
          Expanded(
            child: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _redTet),
                  )
                : vm.errorMessage != null
                    ? _ErrorView(
                        message: vm.errorMessage!,
                        onRetry: () => vm.loadTemplates(),
                      )
                    : _TemplateList(
                        templates: vm.filteredTemplates,
                        onFavoriteTap: (template) {
                          vm.toggleFavorite(template.id, template.isFavorite);
                        },
                        onCardTap: (template) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateWishTemplatePage(
                                templateToEdit: template,
                                isReadOnly: template.isSystem,
                              ),
                            ),
                          ).then((result) async {
                            await vm.loadTemplates();
                            if (result == 'edited' && mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Chỉnh sửa mẫu lời chúc thành công!'),
                                  backgroundColor: Color(0xFF4CAF50),
                                ),
                              );
                            }
                          });
                        },
                        onDeleteTap: (template) async {
                          final confirm = await _showDeleteDialog(context);
                          if (confirm == true) {
                            await vm.deleteTemplate(template.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Xóa mẫu lời chúc thành công!'),
                                  backgroundColor: Color(0xFF4CAF50),
                                ),
                              );
                            }
                            return true;
                          }
                          return false;
                        },
                        // selection props
                        selectionMode: _selectionMode,
                        selectedIds: _selectedTemplateIds,
                        onLongPressTemplate: (tpl) {
                                          if (tpl.isSystem) return; // Do nothing for system templates
                          setState(() {
                                            _selectionMode = true; // Enable selection mode
                            _selectedTemplateIds.add(tpl.id);
                          });
                        },
                        onToggleSelect: (tpl) {
                          setState(() {
                            if (_selectedTemplateIds.contains(tpl.id)) {
                              _selectedTemplateIds.remove(tpl.id);
                            } else {
                              _selectedTemplateIds.add(tpl.id);
                            }
                            if (_selectedTemplateIds.isEmpty) _selectionMode = false;
                          });
                        },
                        onDeleteSelected: () async {
                          if (_selectedTemplateIds.isEmpty) return;
                          final confirm = await _showDeleteDialog(context);
                          if (confirm == true) {
                            for (final id in List<String>.from(_selectedTemplateIds)) {
                              await vm.deleteTemplate(id);
                            }
                            if (mounted) {
                              setState(() {
                                _selectionMode = false;
                                _selectedTemplateIds.clear();
                              });
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Xóa các mẫu đã chọn thành công!'),
                                  backgroundColor: Color(0xFF4CAF50),
                                ),
                              );
                            }
                            await vm.loadTemplates();
                          }
                        },
                      ),
            ),
          const SizedBox(height: 8),
        ],
      ),
      floatingActionButton: _WishFab(onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateWishTemplatePage(),
          ),
        ).then((result) async {
          await vm.loadTemplates();
            if (result == 'created' && mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thêm mẫu lời chúc thành công!'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          }
        });
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const AppBottomNav(currentIndex: NavIndex.wishTemplates),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa mẫu lời chúc này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WishTemplateViewModel vm) {
    bool localSortByUsage = vm.sortByUsage;
    bool localShowOnlyFavorites = vm.showOnlyFavorites;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lọc & Sắp xếp',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Sort by usage
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            localSortByUsage = !localSortByUsage;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort,
                                color: localSortByUsage ? _redTet : Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Sắp xếp theo số lần dùng (nhiều nhất)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: localSortByUsage ? _redTet : Colors.black87,
                                    fontWeight: localSortByUsage ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (localSortByUsage)
                                const Icon(Icons.check, color: _redTet, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const Divider(height: 24),
                    
                    // Filter by favorite
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            localShowOnlyFavorites = !localShowOnlyFavorites;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            children: [
                              Icon(
                                localShowOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                                color: localShowOnlyFavorites ? _yellowFav : Colors.grey[600],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Chỉ hiển thị mẫu yêu thích',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: localShowOnlyFavorites ? _yellowFav : Colors.black87,
                                    fontWeight: localShowOnlyFavorites ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (localShowOnlyFavorites)
                                const Icon(Icons.check, color: _yellowFav, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // OK Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _redTet,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          vm.setSortByUsage(localSortByUsage);
                          vm.setShowOnlyFavorites(localShowOnlyFavorites);
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Áp dụng',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// WIDGET: ERROR VIEW
// ─────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// WIDGET: CUSTOM HEADER
// ─────────────────────────────────────────

class _WishHeader extends StatelessWidget {
  final bool isSearchActive;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;

  const _WishHeader({
    required this.isSearchActive,
    required this.searchController,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
        child: isSearchActive
            ? Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm tiêu đề...',
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF424242)),
                    onPressed: onSearchToggle,
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'Mẫu Các Câu Chúc Tết',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onSearchToggle,
                    icon: const Icon(Icons.search, color: Color(0xFF424242), size: 26),
                    tooltip: 'Tìm kiếm',
                  ),
                  IconButton(
                    onPressed: onFilterTap,
                    icon: const Icon(Icons.filter_list, color: Color(0xFF424242), size: 26),
                    tooltip: 'Bộ lọc',
                  ),
                ],
              ),
      ),
    );
  }
}

class _SelectionHeader extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback? onSelectAll;

  const _SelectionHeader({
    required this.selectedCount,
    required this.onCancel,
    required this.onDelete,
    this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF424242)),
              onPressed: onCancel,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$selectedCount đã chọn',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (onSelectAll != null) ...[
              IconButton(
                onPressed: onSelectAll,
                icon: const Icon(Icons.done_all, color: Color(0xFFE53935)),
                tooltip: 'Chọn tất cả (không chọn mẫu hệ thống)',
              ),
            ],
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// WIDGET: CATEGORY FILTER CHIPS
// ─────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategoryFilter({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _bgChipSelected : _bgChipUnselected,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[i],
                style: TextStyle(
                  color: selected ? Colors.white : _textChipUnselected,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// WIDGET: TEMPLATE LIST
// ─────────────────────────────────────────

class _TemplateList extends StatelessWidget {
  final List<WishTemplate> templates;
  final ValueChanged<WishTemplate> onFavoriteTap;
  final ValueChanged<WishTemplate> onCardTap;
  final Future<bool> Function(WishTemplate) onDeleteTap;
  final bool selectionMode;
  final Set<String> selectedIds;
  final ValueChanged<WishTemplate> onLongPressTemplate;
  final ValueChanged<WishTemplate> onToggleSelect;
  final VoidCallback onDeleteSelected;

  const _TemplateList({
    required this.templates,
    required this.onFavoriteTap,
    required this.onCardTap,
    required this.onDeleteTap,
    required this.selectionMode,
    required this.selectedIds,
    required this.onLongPressTemplate,
    required this.onToggleSelect,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const Center(
        child: Text(
          'Không có lời chúc nào.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: templates.length + 1,
      itemBuilder: (context, i) {
        if (i == templates.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
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

        final tpl = templates[i];

        return Dismissible(
          key: ValueKey(tpl.id),
          // Disable swipe for system templates or when selection mode active
          direction: (selectionMode || tpl.isSystem) ? DismissDirection.none : DismissDirection.endToStart,
          // require ~1/3 of width to trigger dismiss
          dismissThresholds: const {
            DismissDirection.endToStart: 0.33,
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            final deleted = await onDeleteTap(tpl);
            return deleted;
          },
          child: _TemplateCard(
            template: tpl,
            onFavoriteTap: () => onFavoriteTap(tpl),
            onCardTap: () => onCardTap(tpl),
            isSelectionMode: selectionMode,
            isSelected: selectedIds.contains(tpl.id),
            onLongPress: tpl.isSystem ? null : () => onLongPressTemplate(tpl),
            onSelect: tpl.isSystem ? null : () => onToggleSelect(tpl),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// WIDGET: TEMPLATE CARD
// ─────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final WishTemplate template;
  final VoidCallback onFavoriteTap;
  final VoidCallback onCardTap;
  // delete handled by swipe-to-delete in the list
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelect;

  const _TemplateCard({
    required this.template,
    required this.onFavoriteTap,
    required this.onCardTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isSelectionMode && template.isSystem) ? onCardTap : (isSelectionMode ? onSelect : onCardTap),
      onLongPress: template.isSystem ? null : onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSelectionMode)
                (template.isSystem
                    ? const SizedBox(width: 56)
                    : Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        child: Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade400,
                          size: 28,
                        ),
                      )),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Title + Favorite
                    _CardTitleRow(
                      title: template.title,
                      isSystem: template.isSystem,
                      isFavorite: template.isFavorite,
                      onFavoriteTap: onFavoriteTap,
                    ),
                    const SizedBox(height: 10),

                    // Content preview
                    Text(
                      template.content,
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF757575),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Group chips
                    _GroupChips(groups: template.targetGroups),
                    const SizedBox(height: 12),

                    // Footer
                    _CardFooter(
                      usageCount: template.usageCount,
                      isSystem: template.isSystem,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// WIDGET: CARD TITLE ROW
// ─────────────────────────────────────────

class _CardTitleRow extends StatelessWidget {
  final String title;
  final bool isSystem;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const _CardTitleRow({
    required this.title,
    required this.isSystem,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + SYSTEM badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              if (isSystem) ...[
                const SizedBox(height: 6),
                _SystemBadge(),
              ],
            ],
          ),
        ),

        // Favorite icon
        GestureDetector(
          onTap: onFavoriteTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? _yellowFav : Colors.grey[400],
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// WIDGET: SYSTEM BADGE
// ─────────────────────────────────────────

class _SystemBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bgSystemBadge,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'SYSTEM',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _textSystemBadge,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// WIDGET: GROUP CHIPS
// ─────────────────────────────────────────

class _GroupChips extends StatelessWidget {
  final List<String> groups;

  const _GroupChips({required this.groups});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: groups
          .map(
            (g) {
              final cat = ContactCategoryExtension.fromDbString(g);
              final rel = _relationshipInfo(cat);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rel['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  rel['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: rel['textColor'] as Color,
                    letterSpacing: 0.4,
                  ),
                ),
              );
            },
          )
          .toList(),
    );
  }
}

Map<String, dynamic> _relationshipInfo(ContactCategory category) {
  switch (category) {
    case ContactCategory.family:
      return {
        'label': 'GIA ĐÌNH',
        'bgColor': const Color(0xFFE8F5E9),
        'textColor': const Color(0xFF2E7D32),
      };
    case ContactCategory.boss:
      return {
        'label': 'SẾP',
        'bgColor': const Color(0xFFE8EAF6),
        'textColor': const Color(0xFF3949AB),
      };
    case ContactCategory.colleague:
      return {
        'label': 'ĐỒNG NGHIỆP',
        'bgColor': const Color(0xFFE8F5E9),
        'textColor': const Color(0xFF2E7D32),
      };
    case ContactCategory.partner:
      return {
        'label': 'ĐỐI TÁC',
        'bgColor': const Color(0xFFE3F2FD),
        'textColor': const Color(0xFF1976D2),
      };
    case ContactCategory.friend:
      return {
        'label': 'BẠN BÈ',
        'bgColor': const Color(0xFFF3E5F5),
        'textColor': const Color(0xFF8E24AA),
      };
    case ContactCategory.teacher:
      return {
        'label': 'THẦY CÔ',
        'bgColor': const Color(0xFFFFF3E0),
        'textColor': const Color(0xFFE65100),
      };
    case ContactCategory.neighbor:
      return {
        'label': 'HÀNG XÓM',
        'bgColor': const Color(0xFFF1F8E9),
        'textColor': const Color(0xFF558B2F),
      };
    case ContactCategory.other:
      return {
        'label': 'KHÁC',
        'bgColor': const Color(0xFFF5F5F5),
        'textColor': const Color(0xFF757575),
      };
  }
}

// ─────────────────────────────────────────
// WIDGET: CARD FOOTER
// ─────────────────────────────────────────

class _CardFooter extends StatelessWidget {
  final int usageCount;
  final bool isSystem;
  const _CardFooter({
    required this.usageCount,
    required this.isSystem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Đã dùng: $usageCount',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9E9E9E),
          ),
        ),
        const Spacer(),

        // Delete handled by swipe-to-delete; keep footer minimal
      ],
    );
  }
}

class _FooterIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FooterIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────
// WIDGET: FAB
// ─────────────────────────────────────────

class _WishFab extends StatelessWidget {
  final VoidCallback onTap;

  const _WishFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: _redTet,
      elevation: 8,
      shape: const CircleBorder(),
      tooltip: 'Tạo lời chúc mới',
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }
}
