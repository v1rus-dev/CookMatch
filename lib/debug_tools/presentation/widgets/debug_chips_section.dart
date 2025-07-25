import 'package:flutter/material.dart';
import 'package:design/design.dart';

class DebugChipsSection extends StatelessWidget {
  const DebugChipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Чипы', style: AppTextStyles.headline2),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: const Text('Чип 1')),
            Chip(
              label: const Text('Чип 2'),
              backgroundColor: AppColors.primaryLight,
              labelStyle: const TextStyle(color: Colors.white),
            ),
            Chip(
              label: const Text('Чип 3'),
              backgroundColor: AppColors.navigation,
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
