import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';
import '../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final ViewFilter filter;
  const EmptyState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    String title, subtitle;
    IconData icon;

    switch (filter) {
      case ViewFilter.completed:
        title = 'No completed tasks';
        subtitle = 'Check off tasks to see them here';
        icon = Icons.done_all_rounded;
        break;
      case ViewFilter.active:
        title = 'All done!';
        subtitle = 'You have no active tasks. Great work!';
        icon = Icons.celebration_rounded;
        break;
      default:
        title = 'No tasks yet';
        subtitle = 'Tap the button below to create your first task';
        icon = Icons.add_task_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: AppColors.tealGlow,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.teal.withOpacity(0.2), width: 2),
            ),
            child: Icon(icon, color: AppColors.teal, size: 40),
          ),
          const SizedBox(height: 24),
          Text(title,
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(subtitle,
            style: const TextStyle(
              fontSize: 14, color: AppColors.textSecondary, height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}
