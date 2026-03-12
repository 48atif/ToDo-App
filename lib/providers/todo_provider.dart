import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  String _filter = 'all'; // all, active, completed
  TodoCategory? _categoryFilter;
  final _uuid = const Uuid();

  List<Todo> get todos => _filteredTodos;
  String get filter => _filter;
  TodoCategory? get categoryFilter => _categoryFilter;

  int get totalCount => _todos.length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get activeCount => _todos.where((t) => !t.isCompleted).length;
  double get completionRate =>
      _todos.isEmpty ? 0 : completedCount / _todos.length;

  List<Todo> get _filteredTodos {
    var list = _todos;
    if (_categoryFilter != null) {
      list = list.where((t) => t.category == _categoryFilter).toList();
    }
    switch (_filter) {
      case 'active':
        return list.where((t) => !t.isCompleted).toList();
      case 'completed':
        return list.where((t) => t.isCompleted).toList();
      default:
        return list;
    }
  }

  TodoProvider() {
    _loadTodos();
    _addSampleTodos();
  }

  void _addSampleTodos() {
    if (_todos.isNotEmpty) return;
    final now = DateTime.now();
    _todos = [
      Todo(
        id: _uuid.v4(),
        title: 'Morning workout session',
        description: '30 min cardio + 20 min strength',
        priority: Priority.high,
        category: TodoCategory.health,
        createdAt: now,
        dueDate: now,
        dueTime: const TimeOfDay(hour: 7, minute: 0),
      ),
      Todo(
        id: _uuid.v4(),
        title: 'Review project proposal',
        description: 'Check budget and timeline',
        priority: Priority.high,
        category: TodoCategory.work,
        createdAt: now,
        dueDate: now,
        dueTime: const TimeOfDay(hour: 10, minute: 0),
      ),
      Todo(
        id: _uuid.v4(),
        title: 'Read Flutter documentation',
        priority: Priority.medium,
        category: TodoCategory.study,
        createdAt: now,
        dueDate: now.add(const Duration(days: 1)),
      ),
      Todo(
        id: _uuid.v4(),
        title: 'Call mom',
        priority: Priority.medium,
        category: TodoCategory.personal,
        createdAt: now,
        isCompleted: true,
      ),
      Todo(
        id: _uuid.v4(),
        title: 'Buy groceries',
        description: 'Vegetables, fruits, milk',
        priority: Priority.low,
        category: TodoCategory.personal,
        createdAt: now,
        dueDate: now.add(const Duration(days: 1)),
      ),
    ];
    _saveTodos();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setCategoryFilter(TodoCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void addTodo({
    required String title,
    String? description,
    Priority priority = Priority.medium,
    TodoCategory category = TodoCategory.other,
    DateTime? dueDate,
    TimeOfDay? dueTime,
  }) {
    final todo = Todo(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      dueTime: dueTime,
    );
    _todos.insert(0, todo);
    _saveTodos();
    notifyListeners();
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      _saveTodos();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    _saveTodos();
    notifyListeners();
  }

  void updateTodo(Todo updated) {
    final index = _todos.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _todos[index] = updated;
      _saveTodos();
      notifyListeners();
    }
  }

  void reorderTodos(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, item);
    _saveTodos();
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _todos.map((t) => t.toJson()).toList();
    await prefs.setString('todos', jsonEncode(jsonList));
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('todos');
    if (jsonStr != null) {
      final jsonList = jsonDecode(jsonStr) as List;
      _todos = jsonList.map((j) => Todo.fromJson(j)).toList();
      notifyListeners();
    }
  }

  List<Todo> getTodosForDate(DateTime date) {
    return _todos.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == date.year &&
          t.dueDate!.month == date.month &&
          t.dueDate!.day == date.day;
    }).toList();
  }
}
