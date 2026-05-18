import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';
import '../../core/theme/app_theme.dart';

class StatsHeader extends StatelessWidget {
  final TodoProvider provider;
  const StatsHeader({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      child: Column(children: [
        Row(children: [
          _statCard('Total', provider.totalCount.toString(),
              Icons.list_alt_rounded, AppColors.textSecondary),
          const SizedBox(width: 10),
          _statCard('Active', provider.activeCount.toString(),
              Icons.radio_button_unchecked_rounded, AppColors.pink),
          const SizedBox(width: 10),
          _statCard('Done', provider.completedCount.toString(),
              Icons.check_circle_rounded, AppColors.teal),
        ]),
        const SizedBox(height: 12),
        _buildProgressBar(),
      ]),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: color,
              ),
            ),
            Text(label,
              style: const TextStyle(
                fontSize: 10, color: AppColors.textMuted,
                fontWeight: FontWeight.w600, letterSpacing: 0.5,
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildProgressBar() {
    final pct = (provider.progress * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Progress',
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: AppColors.textSecondary, letterSpacing: 0.5,
            ),
          ),
          Text('$pct% complete',
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: provider.progress,
            backgroundColor: AppColors.surfaceLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.teal),
            minHeight: 8,
          ),
        ),
      ]),
    );
  }
}
