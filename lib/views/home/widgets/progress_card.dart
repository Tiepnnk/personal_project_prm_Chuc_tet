import 'package:flutter/material.dart';
import 'package:personal_project_prm/viewmodels/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        final total = vm.totalContacts;
        final called = vm.calledCount;
        final messaged = vm.messagedCount;
        final pending = vm.pendingCount;
        final wished = vm.wishedCount;
        final percent = vm.progressPercent;
        final percentDisplay = vm.progressPercentDisplay;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TIẾN ĐỘ CHÚC TẾT',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: percent,
                          strokeWidth: 9,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFD32F2F)),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$percentDisplay%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              Text(
                                '$wished/$total',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      children: [
                        _buildStatRow(
                            'Đã gọi', '$called', const Color(0xFF4CAF50)),
                        const SizedBox(height: 14),
                        _buildStatRow(
                            'Đã nhắn', '$messaged', const Color(0xFF2196F3)),
                        const SizedBox(height: 14),
                        _buildStatRow(
                            'Chưa gọi', '$pending', Colors.grey[300]!),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String count, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color == Colors.grey[300] ? Colors.grey[600] : color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
