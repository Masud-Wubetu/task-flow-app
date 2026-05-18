import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';
import '../../core/theme/app_theme.dart';

class FilterChipsRow extends StatelessWidget {
  final TodoProvider provider;
  const FilterChipsRow({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(children: [
        _chip('All',       ViewFilter.all,       Icons.apps_rounded),
        const SizedBox(width: 8),
        _chip('Active',    ViewFilter.active,    Icons.pending_rounded),
        const SizedBox(width: 8),
        _chip('Completed', ViewFilter.completed, Icons.done_all_rounded),
      ]),
    );
  }

  Widget _chip(String label, ViewFilter f, IconData icon) {
    final selected = provider.filter == f;
    return GestureDetector(
      onTap: () => provider.setFilter(f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal.withOpacity(0.15) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
            size: 14,
            color: selected ? AppColors.teal : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(label,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: selected ? AppColors.teal : AppColors.textMuted,
            ),
          ),
        ]),
      ),
    );
  }
}
