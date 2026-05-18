import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_card.dart';
import '../widgets/stats_header.dart';
import '../widgets/filter_chips.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_snackbar.dart';
import '../../core/theme/app_theme.dart';
import 'add_edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TodoProvider>().loadTodos();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          // Show snackbars
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.errorMessage != null) {
              AppSnackbar.error(context, provider.errorMessage!);
              provider.clearError();
            }
            if (provider.successMessage != null) {
              AppSnackbar.success(context, provider.successMessage!);
              provider.clearSuccess();
            }
          });

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(provider),
              if (_showSearch) _buildSearchBar(provider),
              SliverToBoxAdapter(child: StatsHeader(provider: provider)),
              SliverToBoxAdapter(child: FilterChipsRow(provider: provider)),
              _buildList(provider),
              if (provider.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.teal),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar(TodoProvider provider) {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: AppColors.background,
      actions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
            color: _showSearch ? AppColors.teal : AppColors.textSecondary,
          ),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                provider.setSearch('');
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
          onPressed: () => provider.loadTodos(refresh: true),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF111827), AppColors.background],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40, right: -40,
                child: Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withOpacity(0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: 20, left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Container(
                        width: 5, height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('TaskFlow',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text('Get things done.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(TodoProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          onChanged: provider.setSearch,
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      provider.setSearch('');
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildList(TodoProvider provider) {
    if (provider.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    final todos = provider.todos;
    if (todos.isEmpty) {
      return SliverFillRemaining(child: EmptyState(filter: provider.filter));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => TodoCard(
            todo: todos[i],
            onToggle: () => provider.toggleTodo(todos[i]),
            onEdit: () => _openEdit(todos[i]),
            onDelete: () => _confirmDelete(todos[i].id),
          ),
          childCount: todos.length,
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) =>
          ChangeNotifierProvider.value(
            value: context.read<TodoProvider>(),
            child: const AddEditPage(),
          ),
        ),
      ),
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.background,
      elevation: 6,
      icon: const Icon(Icons.add_rounded, size: 22),
      label: const Text('New Task',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
    );
  }

  void _openEdit(todo) {
    Navigator.push(context, MaterialPageRoute(builder: (_) =>
      ChangeNotifierProvider.value(
        value: context.read<TodoProvider>(),
        child: AddEditPage(todo: todo),
      ),
    ));
  }

  void _confirmDelete(int id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Delete Task?',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text('This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<TodoProvider>().deleteTodo(id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
