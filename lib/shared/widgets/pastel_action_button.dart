import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PastelActionButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final Color color;
  final VoidCallback onTap;

  const PastelActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.playfulText.withOpacity(0.1), width: 1),
            ),
            child: Center(
              child: icon,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.playfulText),
        ),
      ],
    );
  }
}
