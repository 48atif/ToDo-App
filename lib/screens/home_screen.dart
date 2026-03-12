import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../providers/dnd_provider.dart';
import '../widgets/todo_list_widget.dart';
import '../widgets/stats_header.dart';
import '../widgets/dnd_banner.dart';
import '../widgets/category_filter.dart';
import 'add_todo_screen.dart';
import 'dnd_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dnd = context.watch<DndProvider>();
    final isDnd = dnd.isDndActive;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDnd, dnd),
          if (isDnd)
            SliverToBoxAdapter(
              child: DndBanner(
                schedule: dnd.activeSchedule,
                isManual: dnd.isDndManual,
              ),
            ),
          SliverToBoxAdapter(
            child: StatsHeader(isDnd: isDnd),
          ),
          SliverToBoxAdapter(
            child: _buildFilterTabs(context, isDnd),
          ),
          SliverToBoxAdapter(
            child: CategoryFilter(isDnd: isDnd),
          ),
          SliverToBoxAdapter(
            child: TodoListWidget(isDnd: isDnd),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: isDnd
          ? null
          : ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () => _openAddTodo(context),
                icon: const Icon(Icons.add_rounded, size: 28),
                label: const Text(
                  'Add Task',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                elevation: 12,
              ),
            ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDnd, DndProvider dnd) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: isDnd
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                )
              : null,
        ),
      ),
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDnd ? '🌙 Focus Mode' : '✨ Focus Flow',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDnd ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 13,
                  color: isDnd
                      ? Colors.white.withOpacity(0.6)
                      : Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DndSettingsScreen()),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDnd
                  ? const Color(0xFF6C63FF).withOpacity(0.3)
                  : const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: isDnd
                  ? Border.all(color: const Color(0xFF6C63FF), width: 1.5)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDnd ? Icons.do_not_disturb_on : Icons.do_not_disturb_off,
                  size: 16,
                  color: isDnd ? const Color(0xFF6C63FF) : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  isDnd ? 'DND ON' : 'DND',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDnd ? const Color(0xFF6C63FF) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      expandedHeight: 90,
    );
  }

  Widget _buildFilterTabs(BuildContext context, bool isDnd) {
    final todoProvider = context.watch<TodoProvider>();
    final tabs = [
      ('All', todoProvider.totalCount),
      ('Active', todoProvider.activeCount),
      ('Done', todoProvider.completedCount),
    ];
    final filters = ['all', 'active', 'completed'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDnd
              ? const Color(0xFF16213E)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isSelected = _selectedTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = i);
                  todoProvider.setFilter(filters[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${tabs[i].$1} (${tabs[i].$2})',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDnd ? Colors.white54 : Colors.grey[600]),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! 🌅';
    if (hour < 17) return 'Good afternoon! ☀️';
    if (hour < 21) return 'Good evening! 🌆';
    return 'Good night! 🌙';
  }

  void _openAddTodo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTodoScreen(),
    );
  }
}
