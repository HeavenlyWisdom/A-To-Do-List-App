import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/task.dart';

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>(
  (ref) => TasksNotifier(),
);

class TasksNotifier extends StateNotifier<List<Task>> {
  final Box<Task> _box = Hive.box<Task>('tasks');

  TasksNotifier() : super([]) {
    _loadTasks();
  }

  void _loadTasks() {
    state = _box.values.toList();
  }

  // ---------- READ HELPERS ----------
  List<Task> get activeTasks => state.where((t) => !t.isCompleted).toList();

  List<Task> get completedTasks => state.where((t) => t.isCompleted).toList();

  // ---------- ACTIONS ----------
  void addTask(Task task) {
    _box.put(task.id, task);
    state = [...state, task];
  }

  Future<void> toggleComplete(String id) async {
    final index = state.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final updated = state[index].copyWith(isCompleted: true);
    _box.put(id, updated);

    // Strike-through state
    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];

    // Delay before moving out of Home
    await Future.delayed(const Duration(milliseconds: 450));

    state = [
      ...state.where((t) => t.id != id),
      updated,
    ];
  }

  void restoreTask(String id) {
    final restored = state.firstWhere((t) => t.id == id).copyWith(
          isCompleted: false,
        );

    _box.put(id, restored);

    state = [
      ...state.where((t) => t.id != id),
      restored,
    ];
  }

  void permanentlyDeleteTask(String id) {
    _box.delete(id);
    state = state.where((t) => t.id != id).toList();
  }
}
