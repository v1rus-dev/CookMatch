import 'package:design/design.dart';
import 'package:flutter/material.dart';

class DebugTextSection extends StatelessWidget {
  const DebugTextSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Обычный текст', style: AppTextStyles.body),
        const SizedBox(height: 16),
      ],
    );
  }
}
