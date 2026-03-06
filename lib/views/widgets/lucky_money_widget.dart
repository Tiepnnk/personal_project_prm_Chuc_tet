import 'package:flutter/material.dart';

/// Hiệu ứng Lì xì góc màn hình (Lucky Money Bouncing)
class LuckyMoneyWidget extends StatefulWidget {
  final VoidCallback onTap;

  const LuckyMoneyWidget({super.key, required this.onTap});

  @override
  State<LuckyMoneyWidget> createState() => _LuckyMoneyWidgetState();
}

class _LuckyMoneyWidgetState extends State<LuckyMoneyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    // Tạo Animation nhún nhảy chậm lặp đi lặp lại
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Chạy tiến, chạy lùi

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120, // Cách mép dưới (tránh đè BottomNavigationBar)
      right: 20,   // Nằm góc bên phải
      child: GestureDetector(
        onTap: () {
          // Bóp nút (scale down) nhẹ giả lập touch
          _controller.duration = const Duration(milliseconds: 100);
          _controller.repeat(reverse: true);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _controller.duration = const Duration(seconds: 2);
              _controller.repeat(reverse: true);
            }
          });

          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 56,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.yellow, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.currency_exchange_outlined,
                          color: Colors.yellow,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LÌ XÌ',
                          style: TextStyle(
                            color: Colors.yellow[300],
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
