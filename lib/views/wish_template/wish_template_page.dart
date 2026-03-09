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
          _WishHeader(
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
                          ).then((_) => vm.loadTemplates());
                        },
                        onDeleteTap: (template) async {
                          final confirm = await _showDeleteDialog(context);
                          if (confirm == true) {
                            vm.deleteTemplate(template.id);
                          }
                        },
                      ),
            ),
        ],
      ),
      floatingActionButton: _WishFab(onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateWishTemplatePage(),
          ),
        ).then((_) => vm.loadTemplates());
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
  final ValueChanged<WishTemplate> onDeleteTap;

  const _TemplateList({
    required this.templates,
    required this.onFavoriteTap,
    required this.onCardTap,
    required this.onDeleteTap,
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
      itemCount: templates.length,
      itemBuilder: (context, i) {
        return _TemplateCard(
          template: templates[i],
          onFavoriteTap: () => onFavoriteTap(templates[i]),
          onCardTap: () => onCardTap(templates[i]),
          onDeleteTap: () => onDeleteTap(templates[i]),
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
  final VoidCallback onDeleteTap;

  const _TemplateCard({
    required this.template,
    required this.onFavoriteTap,
    required this.onCardTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
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
                onDeleteTap: onDeleteTap,
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
              final displayName = ContactCategoryExtension.fromDbString(g).displayName;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _bgGroupChip,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF616161),
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

// ─────────────────────────────────────────
// WIDGET: CARD FOOTER
// ─────────────────────────────────────────

class _CardFooter extends StatelessWidget {
  final int usageCount;
  final bool isSystem;
  final VoidCallback onDeleteTap;

  const _CardFooter({
    required this.usageCount,
    required this.isSystem,
    required this.onDeleteTap,
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

        // Delete chỉ hiện với template cá nhân
        if (!isSystem) ...[
          _FooterIconBtn(
            icon: Icons.delete_outline,
            color: const Color(0xFFE53935),
            onTap: onDeleteTap,
          ),
        ],
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
