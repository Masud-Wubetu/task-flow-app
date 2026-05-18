import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../../core/theme/app_theme.dart';

class AddEditPage extends StatefulWidget {
  final TodoModel? todo;
  const AddEditPage({super.key, this.todo});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  late TextEditingController _titleController;
  String _priority = Priority.medium;
  final _formKey = GlobalKey<FormState>();
  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _priority = widget.todo?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TodoProvider>();
    bool success;
    if (_isEditing) {
      success = await provider.updateTodo(widget.todo!, _titleController.text, _priority);
    } else {
      success = await provider.createTodo(_titleController.text, _priority);
    }
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, _) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopIllustration(),
                const SizedBox(height: 32),
                _buildLabel('Task Title'),
                const SizedBox(height: 10),
                _buildTitleField(),
                const SizedBox(height: 28),
                _buildLabel('Priority Level'),
                const SizedBox(height: 12),
                _buildPrioritySelector(),
                const SizedBox(height: 40),
                _buildSubmitButton(provider),
                const SizedBox(height: 16),
                _buildCancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopIllustration() {
    return Center(
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: AppColors.tealGlow,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.teal.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.teal.withOpacity(0.15),
              blurRadius: 24, spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(
          _isEditing ? Icons.edit_rounded : Icons.add_task_rounded,
          color: AppColors.teal, size: 34,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w800,
        color: AppColors.textMuted, letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      maxLines: 3,
      style: const TextStyle(
        color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter a task title';
        if (v.trim().length < 3) return 'Title must be at least 3 characters';
        return null;
      },
      decoration: const InputDecoration(
        hintText: 'What needs to be done?',
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Icon(Icons.task_alt_rounded, color: AppColors.textMuted, size: 20),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final priorities = [
      (Priority.high,   'High',   AppColors.priorityHigh,   Icons.flag_rounded),
      (Priority.medium, 'Medium', AppColors.priorityMedium, Icons.flag_outlined),
      (Priority.low,    'Low',    AppColors.priorityLow,    Icons.outlined_flag_rounded),
    ];

    return Row(
      children: priorities.map((p) {
        final (value, label, color, icon) = p;
        final isSelected = _priority == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? color : AppColors.divider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(children: [
                Icon(icon, color: isSelected ? color : AppColors.textMuted, size: 22),
                const SizedBox(height: 6),
                Text(label,
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: isSelected ? color : AppColors.textMuted,
                  ),
                ),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton(TodoProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: provider.isSubmitting ? null : _submit,
        icon: provider.isSubmitting
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.background, strokeWidth: 2.5),
              )
            : Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded, size: 20),
        label: Text(_isEditing ? 'Save Changes' : 'Create Task'),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel',
          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
