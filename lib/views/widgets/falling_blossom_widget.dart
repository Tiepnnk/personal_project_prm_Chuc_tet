import 'dart:math';
import 'package:flutter/material.dart';

/// Hiệu ứng Hoa đào rơi (Falling Blossoms)
class FallingBlossomWidget extends StatefulWidget {
  final int blossomCount;

  const FallingBlossomWidget({super.key, this.blossomCount = 15});

  @override
  State<FallingBlossomWidget> createState() => _FallingBlossomWidgetState();
}

class _FallingBlossomWidgetState extends State<FallingBlossomWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<_Blossom> _blossoms = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller chạy lặp vô tận (loop) dài 10 giây
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    // Khởi tạo các bông hoa ngẫu nhiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < widget.blossomCount; i++) {
        _blossoms.add(_createBlossom(size));
      }
    });

    _controller.addListener(_updateBlossoms);
  }

  _Blossom _createBlossom(Size size) {
    return _Blossom(
      x: _random.nextDouble() * size.width,
      y: -_random.nextDouble() * size.height, // Bắt đầu từ trên cùng ngẫu nhiên
      size: 10 + _random.nextDouble() * 15,   // Kích thước từ 10->25
      speed: 1.0 + _random.nextDouble() * 2.0, // Tốc độ rơi
      spinStart: _random.nextDouble() * pi * 2,
      spinSpeed: 0.02 + _random.nextDouble() * 0.05,
      color: Colors.pink.withOpacity(0.4 + _random.nextDouble() * 0.4),
    );
  }

  void _updateBlossoms() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    
    for (int i = 0; i < _blossoms.length; i++) {
      var blossom = _blossoms[i];
      blossom.y += blossom.speed;
      blossom.x += sin(_controller.value * 2 * pi * blossom.speed) * 0.8; // Lắc lư ngang
      blossom.spinStart += blossom.spinSpeed; // Xoay vòng

      if (blossom.y > size.height) {
        // Rơi lọt đáy rồi -> Spawn ngược lại lên trên cùng
        _blossoms[i] = _createBlossom(size);
        _blossoms[i].y = -blossom.size;
      }
    }
    setState(() {}); // Repaint
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_blossoms.isEmpty) return const SizedBox.shrink();

    // IgnorePointer để chặn những tap vô tình chạm vào Overlay
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _BlossomPainter(_blossoms),
      ),
    );
  }
}

class _Blossom {
  double x;
  double y;
  double size;
  double speed;
  double spinStart;
  double spinSpeed;
  Color color;

  _Blossom({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.spinStart,
    required this.spinSpeed,
    required this.color,
  });
}

class _BlossomPainter extends CustomPainter {
  final List<_Blossom> blossoms;
  _BlossomPainter(this.blossoms);

  @override
  void paint(Canvas canvas, Size size) {
    for (var blossom in blossoms) {
      final paint = Paint()..color = blossom.color;
      canvas.save();
      canvas.translate(blossom.x, blossom.y);
      canvas.rotate(blossom.spinStart);

      // Vẽ cánh hoa đơn giản (4 cánh tròn nhỏ)
      double r = blossom.size / 3.5;
      canvas.drawCircle(Offset(-r, 0), r, paint);
      canvas.drawCircle(Offset(r, 0), r, paint);
      canvas.drawCircle(Offset(0, -r), r, paint);
      canvas.drawCircle(Offset(0, r), r, paint);
      
      canvas.drawCircle(const Offset(0, 0), r * 0.8, Paint()..color = Colors.yellow.withOpacity(0.6)); // Nhuỵ vàng
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
