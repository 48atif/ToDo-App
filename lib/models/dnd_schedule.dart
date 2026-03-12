import 'package:flutter/material.dart';

class DndSchedule {
  final String id;
  String name;
  TimeOfDay startTime;
  TimeOfDay endTime;
  List<int> activeDays; // 1=Mon, 2=Tue, ..., 7=Sun
  bool isEnabled;
  bool allowUrgentTasks;

  DndSchedule({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.activeDays,
    this.isEnabled = true,
    this.allowUrgentTasks = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startHour': startTime.hour,
        'startMinute': startTime.minute,
        'endHour': endTime.hour,
        'endMinute': endTime.minute,
        'activeDays': activeDays,
        'isEnabled': isEnabled,
        'allowUrgentTasks': allowUrgentTasks,
      };

  factory DndSchedule.fromJson(Map<String, dynamic> json) => DndSchedule(
        id: json['id'],
        name: json['name'],
        startTime: TimeOfDay(hour: json['startHour'], minute: json['startMinute']),
        endTime: TimeOfDay(hour: json['endHour'], minute: json['endMinute']),
        activeDays: List<int>.from(json['activeDays']),
        isEnabled: json['isEnabled'],
        allowUrgentTasks: json['allowUrgentTasks'],
      );

  bool isActiveNow() {
    final now = DateTime.now();
    final currentDay = now.weekday; // 1=Mon, 7=Sun
    if (!activeDays.contains(currentDay)) return false;

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    if (endMinutes > startMinutes) {
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      // Overnight schedule
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
    }
  }

  String get timeRangeString {
    String formatTime(TimeOfDay t) {
      final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final minute = t.minute.toString().padLeft(2, '0');
      final period = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  String get daysString {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (activeDays.length == 7) return 'Every day';
    if (activeDays.toSet().containsAll({1, 2, 3, 4, 5}) && activeDays.length == 5) return 'Weekdays';
    if (activeDays.toSet().containsAll({6, 7}) && activeDays.length == 2) return 'Weekends';
    return activeDays.map((d) => dayNames[d - 1]).join(', ');
  }
}
