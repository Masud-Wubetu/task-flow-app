import 'package:flutter/material.dart';
import '../../data/models/todo_model.dart';
import '../../core/theme/app_theme.dart';

class TodoCard extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _priorityColor {
    switch (todo.priority) {
      case Priority.high:   return AppColors.priorityHigh;
      case Priority.medium: return AppColors.priorityMedium;
      default:              return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('todo-${todo.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 26),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: todo.completed
              ? AppColors.surface.withOpacity(0.6)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: todo.completed ? AppColors.divider : _priorityColor.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8, offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              _buildPriorityBar(),
              const SizedBox(width: 12),
              _buildCheckbox(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent()),
              _buildMenu(context),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBar() {
    return Container(
      width: 4, height: 52,
      decoration: BoxDecoration(
        color: todo.completed
            ? AppColors.textMuted
            : _priorityColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26, height: 26,
        decoration: BoxDecoration(
          color: todo.completed ? AppColors.teal : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: todo.completed ? AppColors.teal : AppColors.textMuted,
            width: 2,
          ),
        ),
        child: todo.completed
            ? const Icon(Icons.check_rounded, color: AppColors.background, size: 16)
            : null,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          todo.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: todo.completed ? AppColors.textMuted : AppColors.textPrimary,
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            decorationColor: AppColors.textMuted,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              todo.priority.toUpperCase(),
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: todo.completed ? AppColors.textMuted : _priorityColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '#${todo.id}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ]),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded,
          color: AppColors.textMuted, size: 20),
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (v) {
        if (v == 'edit')   onEdit();
        if (v == 'delete') onDelete();
        if (v == 'toggle') onToggle();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(children: [
            Icon(
              todo.completed ? Icons.radio_button_unchecked_rounded : Icons.check_circle_outline_rounded,
              color: AppColors.teal, size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              todo.completed ? 'Mark Active' : 'Mark Done',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ]),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 10),
            const Text('Edit', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            const Text('Delete', style: TextStyle(color: AppColors.error, fontSize: 13)),
          ]),
        ),
      ],
    );
  }
}
