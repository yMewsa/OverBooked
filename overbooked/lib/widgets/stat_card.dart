import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A styled metric card for displaying a single reading statistic.
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: AppTheme.accent),
            ),
            const SizedBox(height: 10),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
