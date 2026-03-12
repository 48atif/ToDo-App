import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class CategoryFilter extends StatelessWidget {
  final bool isDnd;
  const CategoryFilter({super.key, required this.isDnd});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final categories = [null, ...TodoCategory.values];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = provider.categoryFilter == cat;
          final mock = cat != null
              ? Todo(id: '', title: '', createdAt: DateTime.now(), category: cat)
              : null;

          return GestureDetector(
            onTap: () => provider.setCategoryFilter(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : (isDnd ? const Color(0xFF16213E) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(22),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDnd ? Colors.white12 : Colors.grey[200]!,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (mock != null) ...[
                    Icon(
                      mock.categoryIcon,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : (isDnd ? Colors.white54 : Colors.grey[600]),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    cat == null ? 'All' : mock!.categoryName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDnd ? Colors.white54 : Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
