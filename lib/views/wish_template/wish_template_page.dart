import 'package:flutter/material.dart';
import 'package:personal_project_prm/views/widgets/app_bottom_nav.dart';
import 'package:personal_project_prm/views/wish_template/create_wish_template_page.dart';

// ─────────────────────────────────────────
// MOCK DATA MODEL
// ─────────────────────────────────────────

class WishTemplateMock {
  final String title;
  final String content;
  final bool isSystem;
  bool isFavorite;
  final List<String> groups;
  final int usageCount;

  WishTemplateMock({
    required this.title,
    required this.content,
    required this.isSystem,
    required this.isFavorite,
    required this.groups,
    required this.usageCount,
  });
}

final List<WishTemplateMock> _mockTemplates = [
  WishTemplateMock(
    title: 'Chúc Tết ngắn gọn, ý nghĩa',
    content:
        '"Năm mới Ất Tỵ, kính chúc {{ten}} dồi dào sức khỏe, vạn sự như ý, an khang thịnh vượng."',
    isSystem: true,
    isFavorite: true,
    groups: ['GIA ĐÌNH', 'SẾP'],
    usageCount: 12,
  ),
  WishTemplateMock(
    title: 'Chúc bạn bè vui nhộn',
    content:
        '"Chúc {{ten}} năm mới tiền vào như nước sông Đà, tiền ra nhỏ giọt như cà phê phin. Sớm có bồ nha!"',
    isSystem: true,
    isFavorite: false,
    groups: ['BẠN BÈ'],
    usageCount: 5,
  ),
  WishTemplateMock(
    title: 'Lời chúc do tôi tự soạn',
    content:
        '"Cảm ơn sếp {{ten}} đã dẫn dắt team trong năm qua. Chúc sếp năm mới bùng nổ doanh số, sức..."',
    isSystem: false,
    isFavorite: true,
    groups: ['SẾP'],
    usageCount: 2,
  ),
  WishTemplateMock(
    title: 'Chúc sức khỏe ông bà',
    content:
        '"Cháu kính chúc {{ten}} sống lâu trăm tuổi, thân thể khỏe mạnh, vui vẻ cùng con cháu mỗi dịp Xuân..."',
    isSystem: true,
    isFavorite: false,
    groups: ['GIA ĐÌNH'],
    usageCount: 0,
  ),
  WishTemplateMock(
    title: 'Chúc đối tác chuyên nghiệp',
    content:
        '"Nhân dịp Tết {{nam_am}}, công ty trân trọng gửi lời chúc đến {{ten}} và quý đối tác..."',
    isSystem: true,
    isFavorite: false,
    groups: ['ĐỐI TÁC'],
    usageCount: 8,
  ),
  WishTemplateMock(
    title: 'Chúc thầy cô kính trọng',
    content:
        '"Em {{ten_minh}} kính chúc {{ten}} năm mới sức khỏe dồi dào, hạnh phúc và thành công mỹ mãn..."',
    isSystem: false,
    isFavorite: false,
    groups: ['THẦY CÔ'],
    usageCount: 3,
  ),
];

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

class WishTemplatePage extends StatefulWidget {
  const WishTemplatePage({super.key});

  @override
  State<WishTemplatePage> createState() => _WishTemplatePageState();
}

class _WishTemplatePageState extends State<WishTemplatePage> {
  int _selectedCategory = 0;
  int _selectedNavIndex = 2;

  List<WishTemplateMock> get _filteredTemplates {
    if (_selectedCategory == 0) return _mockTemplates;
    final keyword = _categories[_selectedCategory].toUpperCase();
    return _mockTemplates
        .where((t) => t.groups.any((g) => g.contains(keyword)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScreen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WishHeader(
            onSearchTap: () {},
            onFilterTap: () {},
          ),
          _CategoryFilter(
            categories: _categories,
            selectedIndex: _selectedCategory,
            onSelected: (i) => setState(() => _selectedCategory = i),
          ),
          Expanded(
            child: _TemplateList(
              templates: _filteredTemplates,
              onFavoriteTap: (template) {
                setState(() => template.isFavorite = !template.isFavorite);
              },
              onViewTap: (_) {},
              onEditTap: (_) {},
              onDeleteTap: (_) {},
            ),
          ),
        ],
      ),
      floatingActionButton: _WishFab(onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateWishTemplatePage()),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const AppBottomNav(currentIndex: NavIndex.wishTemplates),
    );
  }
}

// ─────────────────────────────────────────
// WIDGET: CUSTOM HEADER
// ─────────────────────────────────────────

class _WishHeader extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  const _WishHeader({required this.onSearchTap, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Kho lời chúc Tết',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            IconButton(
              onPressed: onSearchTap,
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
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
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
  final List<WishTemplateMock> templates;
  final ValueChanged<WishTemplateMock> onFavoriteTap;
  final ValueChanged<WishTemplateMock> onViewTap;
  final ValueChanged<WishTemplateMock> onEditTap;
  final ValueChanged<WishTemplateMock> onDeleteTap;

  const _TemplateList({
    required this.templates,
    required this.onFavoriteTap,
    required this.onViewTap,
    required this.onEditTap,
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
          onViewTap: () => onViewTap(templates[i]),
          onEditTap: () => onEditTap(templates[i]),
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
  final WishTemplateMock template;
  final VoidCallback onFavoriteTap;
  final VoidCallback onViewTap;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const _TemplateCard({
    required this.template,
    required this.onFavoriteTap,
    required this.onViewTap,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            _GroupChips(groups: template.groups),
            const SizedBox(height: 12),

            // Footer
            _CardFooter(
              usageCount: template.usageCount,
              isSystem: template.isSystem,
              onViewTap: onViewTap,
              onEditTap: onEditTap,
              onDeleteTap: onDeleteTap,
            ),
          ],
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
            (g) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _bgGroupChip,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                g,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF616161),
                  letterSpacing: 0.4,
                ),
              ),
            ),
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
  final VoidCallback onViewTap;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const _CardFooter({
    required this.usageCount,
    required this.isSystem,
    required this.onViewTap,
    required this.onEditTap,
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

        // View icon (always visible)
        _FooterIconBtn(
          icon: Icons.remove_red_eye_outlined,
          color: Color(0xFF9E9E9E),
          onTap: onViewTap,
        ),

        // Edit & Delete chỉ hiện với template cá nhân
        if (!isSystem) ...[
          const SizedBox(width: 2),
          _FooterIconBtn(
            icon: Icons.edit_outlined,
            color: Color(0xFF9E9E9E),
            onTap: onEditTap,
          ),
          const SizedBox(width: 2),
          _FooterIconBtn(
            icon: Icons.delete_outline,
            color: Color(0xFFE53935),
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

