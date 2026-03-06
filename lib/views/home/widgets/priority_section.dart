import 'package:flutter/material.dart';

class PrioritySection extends StatelessWidget {
  const PrioritySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Ưu tiên hôm nay',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPriorityCard(
          avatarText: 'H',
          avatarBg: Colors.orange[100]!,
          avatarTextColor: Colors.deepOrange,
          name: 'Sếp Hùng',
          badgeText: 'QUAN TRỌNG',
          badgeColor: Colors.red[50]!,
          badgeTextColor: Colors.red,
          subtitle: 'Giám đốc điều hành',
          actionIcon: Icons.phone,
        ),
        _buildPriorityCard(
          avatarText: 'BM',
          avatarBg: Colors.pink[50]!,
          avatarTextColor: Colors.pink,
          name: 'Bố Mẹ',
          badgeText: 'GIA ĐÌNH',
          badgeColor: Colors.orange[50]!,
          badgeTextColor: Colors.orange[800]!,
          subtitle: 'Gọi về quê',
          actionIcon: Icons.videocam,
        ),
        _buildPriorityCard(
          avatarText: 'A',
          avatarBg: Colors.blue[50]!,
          avatarTextColor: Colors.blue,
          name: 'Anh Minh (Đối tác)',
          badgeText: 'CÔNG VIỆC',
          badgeColor: Colors.blue[50]!,
          badgeTextColor: Colors.blue[700]!,
          subtitle: 'Dự án Xuân 2026',
          actionIcon: Icons.chat,
        ),
      ],
    );
  }

  Widget _buildPriorityCard({
    required String avatarText,
    required Color avatarBg,
    required Color avatarTextColor,
    required String name,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required String subtitle,
    required IconData actionIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: avatarBg,
            child: Text(
              avatarText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: avatarTextColor,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E1E1E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          color: badgeTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF1FC377), // Xanh lá
              shape: BoxShape.circle,
            ),
            child: Icon(actionIcon, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}
