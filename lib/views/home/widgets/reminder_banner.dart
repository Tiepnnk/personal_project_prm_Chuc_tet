import 'package:flutter/material.dart';

class ReminderBanner extends StatelessWidget {
  const ReminderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background icon/shape for decoration
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.pets, // Mèo/Thỏ placeholder
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.yellow, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'LỜI NHẮC',
                    style: TextStyle(
                      color: Colors.yellow[600],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Chỉ còn 3 ngày nữa là Tết!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hoàn thành 35 lời chúc còn lại để đón Tết trọn vẹn.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
