import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class StatsHeader extends StatelessWidget {
  final bool isDnd;
  const StatsHeader({super.key, required this.isDnd});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final rate = provider.completionRate;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDnd
            ? const LinearGradient(
                colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDnd ? const Color(0xFF6C63FF) : const Color(0xFF6C63FF))
                .withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: 'Total',
                value: '${provider.totalCount}',
                icon: Icons.task_alt_rounded,
              ),
              _StatItem(
                label: 'Active',
                value: '${provider.activeCount}',
                icon: Icons.radio_button_unchecked_rounded,
              ),
              _StatItem(
                label: 'Done',
                value: '${provider.completedCount}',
                icon: Icons.check_circle_rounded,
              ),
              _StatItem(
                label: 'Progress',
                value: '${(rate * 100).toInt()}%',
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDnd ? const Color(0xFF6C63FF) : Colors.white,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rate == 1.0
                ? '🎉 All tasks complete!'
                : rate >= 0.5
                    ? '💪 Great progress, keep it up!'
                    : '🚀 Let\'s crush those tasks!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
