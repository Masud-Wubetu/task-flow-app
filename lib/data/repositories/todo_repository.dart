import '../models/todo_model.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class TodoRepository {
  final ApiService _api;
  TodoRepository({ApiService? api}) : _api = api ?? ApiService();

  // READ - fetch paginated todos
  Future<List<TodoModel>> fetchTodos({int limit = 20, int start = 0}) async {
    final data = await _api.get(ApiConstants.todos, params: {
      '_limit': limit.toString(),
      '_start': start.toString(),
    });
    return (data as List).map((e) => TodoModel.fromJson(e)).toList();
  }

  // READ - fetch single todo
  Future<TodoModel> fetchTodoById(int id) async {
    final data = await _api.get(ApiConstants.todoById(id));
    return TodoModel.fromJson(data);
  }

  // CREATE
  Future<TodoModel> createTodo({
    required String title,
    required String priority,
    int userId = 1,
  }) async {
    final data = await _api.post(ApiConstants.todos, {
      'title':     title,
      'completed': false,
      'userId':    userId,
    });
    return TodoModel(
      id:        data['id'] as int,
      userId:    userId,
      title:     title,
      completed: false,
      priority:  priority,
    );
  }

  // UPDATE - full update
  Future<TodoModel> updateTodo(TodoModel todo) async {
    await _api.put(ApiConstants.todoById(todo.id), todo.toJson());
    return todo;
  }

  // UPDATE - toggle completion
  Future<TodoModel> toggleTodo(TodoModel todo) async {
    final updated = todo.copyWith(completed: !todo.completed);
    await _api.put(ApiConstants.todoById(todo.id), updated.toJson());
    return updated;
  }

  // DELETE
  Future<void> deleteTodo(int id) async {
    await _api.delete(ApiConstants.todoById(id));
  }
}
