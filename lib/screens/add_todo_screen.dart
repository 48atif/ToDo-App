import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class AddTodoScreen extends StatefulWidget {
  final Todo? editTodo;
  const AddTodoScreen({super.key, this.editTodo});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  Priority _priority = Priority.medium;
  TodoCategory _category = TodoCategory.other;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void initState() {
    super.initState();
    if (widget.editTodo != null) {
      _titleController.text = widget.editTodo!.title;
      _descController.text = widget.editTodo!.description ?? '';
      _priority = widget.editTodo!.priority;
      _category = widget.editTodo!.category;
      _dueDate = widget.editTodo!.dueDate;
      _dueTime = widget.editTodo!.dueTime;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.editTodo == null ? 'New Task ✨' : 'Edit Task',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _titleController,
              hint: 'What needs to be done?',
              icon: Icons.edit_rounded,
              fontSize: 16,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descController,
              hint: 'Add a note (optional)',
              icon: Icons.notes_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            _buildPrioritySelector(),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildDateTimePicker(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    double fontSize = 14,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: Priority.values.map((p) {
            final isSelected = _priority == p;
            final color = _priorityColor(p);
            final label = p.name[0].toUpperCase() + p.name.substring(1);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _priority = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: color, width: 2) : null,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? color : Colors.grey[500],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.high: return const Color(0xFFFF4757);
      case Priority.medium: return const Color(0xFFFF9F43);
      case Priority.low: return const Color(0xFF2ED573);
    }
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: TodoCategory.values.map((c) {
              final isSelected = _category == c;
              final todo = _mockTodoForCategory(c);
              return GestureDetector(
                onTap: () => setState(() => _category = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        todo.categoryIcon,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        todo.categoryName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Todo _mockTodoForCategory(TodoCategory c) => Todo(
        id: '',
        title: '',
        createdAt: DateTime.now(),
        category: c,
      );

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 18, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 8),
                  Text(
                    _dueDate == null
                        ? 'Set date'
                        : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                    style: TextStyle(
                      color: _dueDate == null ? Colors.grey[400] : const Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 18, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 8),
                  Text(
                    _dueTime == null
                        ? 'Set time'
                        : _dueTime!.format(context),
                    style: TextStyle(
                      color: _dueTime == null ? Colors.grey[400] : const Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF6C63FF).withOpacity(0.4),
        ),
        child: Text(
          widget.editTodo == null ? 'Add Task' : 'Save Changes',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    final provider = context.read<TodoProvider>();
    if (widget.editTodo == null) {
      provider.addTodo(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        priority: _priority,
        category: _category,
        dueDate: _dueDate,
        dueTime: _dueTime,
      );
    } else {
      provider.updateTodo(
        widget.editTodo!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          priority: _priority,
          category: _category,
          dueDate: _dueDate,
          dueTime: _dueTime,
        ),
      );
    }
    Navigator.pop(context);
  }
}
