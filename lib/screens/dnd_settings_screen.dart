import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dnd_provider.dart';
import '../models/dnd_schedule.dart';

class DndSettingsScreen extends StatelessWidget {
  const DndSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dnd = context.watch<DndProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'DND Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildManualDndCard(context, dnd),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Schedules',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddScheduleDialog(context, dnd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...dnd.schedules.map((s) => _buildScheduleCard(context, s, dnd)),
            if (dnd.schedules.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.do_not_disturb_off, size: 60, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text('No schedules yet', style: TextStyle(color: Colors.white.withOpacity(0.4))),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildManualDndCard(BuildContext context, DndProvider dnd) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dnd.isDndActive
              ? [const Color(0xFF6C63FF), const Color(0xFF8B5CF6)]
              : [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: dnd.isDndActive
            ? Border.all(color: const Color(0xFF6C63FF), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌙 Do Not Disturb',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dnd.isDndActive ? 'Active — tasks paused' : 'Inactive',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: dnd.isDndManual,
                onChanged: (_) => dnd.toggleManualDnd(),
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
          if (dnd.isDndActive && !dnd.isDndManual) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Auto: ${dnd.activeSchedule?.name ?? "Schedule active"}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, DndSchedule schedule, DndProvider dnd) {
    final isActive = schedule.isActiveNow() && schedule.isEnabled;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(18),
        border: isActive
            ? Border.all(color: const Color(0xFF6C63FF), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: schedule.isEnabled
                  ? const Color(0xFF6C63FF).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.do_not_disturb_on,
              color: schedule.isEnabled ? const Color(0xFF6C63FF) : Colors.grey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      schedule.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.timeRangeString,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                ),
                Text(
                  schedule.daysString,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch.adaptive(
                value: schedule.isEnabled,
                onChanged: (_) => dnd.toggleSchedule(schedule.id),
                activeColor: const Color(0xFF6C63FF),
              ),
              GestureDetector(
                onTap: () => _confirmDelete(context, schedule, dnd),
                child: Icon(Icons.delete_rounded, size: 18, color: Colors.white.withOpacity(0.3)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'During DND, tasks are shown but you won\'t receive notifications. Scheduled tasks during DND are marked for review.',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DndSchedule schedule, DndProvider dnd) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Schedule', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${schedule.name}"?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              dnd.deleteSchedule(schedule.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF4757))),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context, DndProvider dnd) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddScheduleSheet(dnd: dnd),
    );
  }
}

class _AddScheduleSheet extends StatefulWidget {
  final DndProvider dnd;
  const _AddScheduleSheet({required this.dnd});

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  final _nameController = TextEditingController(text: 'New Schedule');
  TimeOfDay _start = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 7, minute: 0);
  List<int> _days = [1, 2, 3, 4, 5, 6, 7];

  @override
  Widget build(BuildContext context) {
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 24, right: 24, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Add DND Schedule', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Schedule name',
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0F0E17),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _timePicker('Start', _start, (t) => setState(() => _start = t))),
              const SizedBox(width: 12),
              Expanded(child: _timePicker('End', _end, (t) => setState(() => _end = t))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = i + 1;
              final isSelected = _days.contains(day);
              return GestureDetector(
                onTap: () => setState(() {
                  isSelected ? _days.remove(day) : _days.add(day);
                }),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF0F0E17),
                  child: Text(dayNames[i], style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_days.isEmpty) return;
                widget.dnd.addSchedule(DndSchedule(
                  id: widget.dnd.createScheduleId(),
                  name: _nameController.text,
                  startTime: _start,
                  endTime: _end,
                  activeDays: _days,
                ));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timePicker(String label, TimeOfDay time, Function(TimeOfDay) onPick) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF0F0E17), borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 4),
            Text(time.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
