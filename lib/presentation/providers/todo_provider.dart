import 'package:flutter/foundation.dart';
import '../../data/models/todo_model.dart';
import '../../data/repositories/todo_repository.dart';

enum ViewFilter { all, active, completed }

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repo;
  TodoProvider({TodoRepository? repo}) : _repo = repo ?? TodoRepository();

  // ── State ──────────────────────────────────────────────
  List<TodoModel> _todos      = [];
  bool   _isLoading           = false;
  bool   _isLoadingMore       = false;
  bool   _isSubmitting        = false;
  String? _errorMessage;
  String? _successMessage;
  ViewFilter _filter          = ViewFilter.all;
  String _searchQuery         = '';
  int    _page                = 0;
  bool   _hasMore             = true;
  static const _pageSize      = 20;

  // ── Getters ────────────────────────────────────────────
  bool   get isLoading      => _isLoading;
  bool   get isLoadingMore  => _isLoadingMore;
  bool   get isSubmitting   => _isSubmitting;
  String? get errorMessage  => _errorMessage;
  String? get successMessage=> _successMessage;
  ViewFilter get filter     => _filter;
  String get searchQuery    => _searchQuery;
  bool   get hasMore        => _hasMore;

  List<TodoModel> get todos {
    var list = List<TodoModel>.from(_todos);
    // filter
    if (_filter == ViewFilter.active)    list = list.where((t) => !t.completed).toList();
    if (_filter == ViewFilter.completed) list = list.where((t) => t.completed).toList();
    // search
    if (_searchQuery.isNotEmpty) {
      list = list.where((t) =>
        t.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  int get totalCount     => _todos.length;
  int get completedCount => _todos.where((t) => t.completed).length;
  int get activeCount    => _todos.where((t) => !t.completed).length;
  double get progress    => _todos.isEmpty ? 0 : completedCount / totalCount;

  // ── Actions ────────────────────────────────────────────

  Future<void> loadTodos({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _hasMore = true;
      _todos.clear();
    }
    if (!_hasMore) return;
    if (_page == 0) {
      _setLoading(true);
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }
    _clearMessages();
    try {
      final fetched = await _repo.fetchTodos(
        limit: _pageSize,
        start: _page * _pageSize,
      );
      if (fetched.length < _pageSize) _hasMore = false;
      _todos.addAll(fetched);
      _page++;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading     = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createTodo(String title, String priority) async {
    if (title.trim().isEmpty) {
      _errorMessage = 'Task title cannot be empty.';
      notifyListeners();
      return false;
    }
    _setSubmitting(true);
    try {
      final newTodo = await _repo.createTodo(
        title: title.trim(),
        priority: priority,
      );
      _todos.insert(0, newTodo);
      _successMessage = 'Task created successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateTodo(TodoModel todo, String newTitle, String newPriority) async {
    if (newTitle.trim().isEmpty) {
      _errorMessage = 'Task title cannot be empty.';
      notifyListeners();
      return false;
    }
    _setSubmitting(true);
    try {
      final updated = todo.copyWith(title: newTitle.trim(), priority: newPriority);
      await _repo.updateTodo(updated);
      final idx = _todos.indexWhere((t) => t.id == todo.id);
      if (idx != -1) _todos[idx] = updated;
      _successMessage = 'Task updated!';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<void> toggleTodo(TodoModel todo) async {
    // Optimistic update
    final idx = _todos.indexWhere((t) => t.id == todo.id);
    if (idx == -1) return;
    _todos[idx] = todo.copyWith(completed: !todo.completed);
    notifyListeners();
    try {
      await _repo.toggleTodo(todo);
    } catch (e) {
      // Revert on failure
      _todos[idx] = todo;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(int id) async {
    final backup = List<TodoModel>.from(_todos);
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
    try {
      await _repo.deleteTodo(id);
      _successMessage = 'Task deleted.';
      notifyListeners();
    } catch (e) {
      _todos = backup;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setFilter(ViewFilter f) {
    _filter = f;
    notifyListeners();
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void clearError()   { _errorMessage   = null; notifyListeners(); }
  void clearSuccess() { _successMessage = null; notifyListeners(); }

  // ── Helpers ────────────────────────────────────────────
  void _setLoading(bool v)    { _isLoading    = v; notifyListeners(); }
  void _setSubmitting(bool v) { _isSubmitting = v; notifyListeners(); }
  void _clearMessages()       { _errorMessage = null; _successMessage = null; }
}
