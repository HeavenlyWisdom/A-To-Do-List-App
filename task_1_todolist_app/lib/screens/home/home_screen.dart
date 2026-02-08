import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/task_provider.dart';
import '../../data/models/task.dart';
import '../../widgets/add_edit_task_dialog.dart';
import '../history/completed_tasks_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: const [
                _Header(),
                SizedBox(height: 16),
                Expanded(child: _TaskList()),
                SizedBox(height: 12),
                _BottomActions(),
                SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- HEADER ---------------- */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Text(
        'TASKSPAPER',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/* ---------------- TASK LIST ---------------- */

class _TaskList extends ConsumerWidget {
  const _TaskList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks =
        ref.watch(tasksProvider).where((t) => !t.isCompleted).toList();

    if (tasks.isEmpty) {
      return Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: 1,
          child: Text(
            'No tasks yet\nAdd your first task!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary.withOpacity(0.35),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskTile(task: task),
        );
      },
    );
  }
}

/* ---------------- TASK TILE ---------------- */

class TaskTile extends ConsumerWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: task.isCompleted
          ? const SizedBox.shrink(key: ValueKey('completed'))
          : _TaskContent(task: task),
    );
  }
}

/* ---------------- TASK CONTENT ---------------- */

class _TaskContent extends ConsumerWidget {
  final Task task;

  const _TaskContent({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      key: ValueKey(task.id),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.play_arrow_rounded, color: AppColors.iconPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
              child: Text(task.title),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.crop_square_outlined,
              color: AppColors.iconPrimary,
            ),
            onPressed: () {
              ref.read(tasksProvider.notifier).toggleComplete(task.id);
            },
          ),
        ],
      ),
    );
  }
}

/* ---------------- BOTTOM ACTIONS ---------------- */

class _BottomActions extends ConsumerWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // History (LEFT)
          IconButton(
            icon: Icon(Icons.history, color: AppColors.iconPrimary, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CompletedTasksScreen(),
                ),
              );
            },
          ),

          // Add Task (CENTER)
          GestureDetector(
            onTap: () async {
              final text = await showDialog<String>(
                context: context,
                builder: (_) => const AddEditTaskDialog(),
              );

              if (text != null && text.trim().isNotEmpty) {
                ref.read(tasksProvider.notifier).addTask(
                      Task(title: text.trim(), priority: 1),
                    );
              }
            },
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Transform.rotate(
                  angle: -0.785398,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),

          // Empty space to balance layout
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
