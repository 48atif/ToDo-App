import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../screens/add_todo_screen.dart';

class TodoListWidget extends StatelessWidget {
  final bool isDnd;
  const TodoListWidget({super.key, required this.isDnd});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final todos = provider.todos;

    if (todos.isEmpty) {
      return _buildEmptyState(isDnd);
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: todos.length,
      onReorder: provider.reorderTodos,
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: animation.drive(Tween(begin: 1.0, end: 1.05)),
          child: child,
        ),
      ),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoCard(
          key: ValueKey(todo.id),
          todo: todo,
          isDnd: isDnd,
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDnd) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Text(
              isDnd ? '🌙' : '✨',
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              isDnd ? 'Rest & Recharge' : 'All clear!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDnd ? Colors.white70 : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDnd
                  ? 'No tasks demanding your attention'
                  : 'Add your first task to get started',
              style: TextStyle(
                color: isDnd ? Colors.white38 : Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoCard extends StatefulWidget {
  final Todo todo;
  final bool isDnd;
  const TodoCard({super.key, required this.todo, required this.isDnd});

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDeleting = false;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDnd = widget.isDnd;
    final todo = widget.todo;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => FadeTransition(
        opacity: _controller,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onHorizontalDragUpdate: (d) {
          setState(() => _dragOffset += d.delta.dx);
        },
        onHorizontalDragEnd: (d) {
          if (_dragOffset < -80) {
            _deleteTodo();
          } else if (_dragOffset > 80) {
            _editTodo();
          }
          setState(() => _dragOffset = 0);
        },
        child: Transform.translate(
          offset: Offset(_dragOffset * 0.3, 0),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDnd ? const Color(0xFF16213E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDnd
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: todo.isCompleted
                  ? Border.all(color: const Color(0xFF2ED573).withOpacity(0.3), width: 1.5)
                  : todo.priority == Priority.high
                      ? Border.all(color: todo.priorityColor.withOpacity(0.3), width: 1.5)
                      : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCheckbox(),
                  const SizedBox(width: 14),
                  Expanded(child: _buildContent(isDnd)),
                  _buildTrailing(isDnd),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<TodoProvider>().toggleTodo(widget.todo.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.todo.isCompleted
              ? const Color(0xFF2ED573)
              : Colors.transparent,
          border: Border.all(
            color: widget.todo.isCompleted
                ? const Color(0xFF2ED573)
                : widget.todo.priorityColor,
            width: 2.5,
          ),
        ),
        child: widget.todo.isCompleted
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildContent(bool isDnd) {
    final todo = widget.todo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          todo.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: todo.isCompleted
                ? (isDnd ? Colors.white30 : Colors.grey[400])
                : (isDnd ? Colors.white : const Color(0xFF1A1A2E)),
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        if (todo.description != null && todo.description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            todo.description!,
            style: TextStyle(
              fontSize: 12,
              color: isDnd ? Colors.white38 : Colors.grey[400],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChip(
              icon: todo.categoryIcon,
              label: todo.categoryName,
              isDnd: isDnd,
            ),
            if (todo.dueDate != null) ...[
              const SizedBox(width: 6),
              _buildChip(
                icon: Icons.calendar_today_rounded,
                label: _formatDate(todo.dueDate!),
                isDnd: isDnd,
                isOverdue: todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted,
              ),
            ],
            if (todo.dueTime != null && todo.dueDate != null) ...[
              const SizedBox(width: 6),
              _buildChip(
                icon: Icons.access_time_rounded,
                label: todo.dueTime!.format(context),
                isDnd: isDnd,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required bool isDnd,
    bool isOverdue = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue
            ? const Color(0xFFFF4757).withOpacity(0.15)
            : (isDnd
                ? Colors.white.withOpacity(0.07)
                : const Color(0xFFF8F7FF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: isOverdue ? const Color(0xFFFF4757) : Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isOverdue ? const Color(0xFFFF4757) : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(bool isDnd) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.todo.priorityColor,
          ),
        ),
        const SizedBox(height: 8),
        ReorderableDragStartListener(
          index: context.watch<TodoProvider>().todos.indexOf(widget.todo),
          child: Icon(
            Icons.drag_indicator_rounded,
            size: 18,
            color: isDnd ? Colors.white24 : Colors.grey[300],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return '${date.day}/${date.month}';
  }

  void _deleteTodo() {
    HapticFeedback.mediumImpact();
    context.read<TodoProvider>().deleteTodo(widget.todo.id);
  }

  void _editTodo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTodoScreen(editTodo: widget.todo),
    );
  }
}
