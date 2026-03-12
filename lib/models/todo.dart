import 'package:flutter/material.dart';

enum Priority { low, medium, high }
enum TodoCategory { work, personal, health, study, other }

class Todo {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  Priority priority;
  TodoCategory category;
  DateTime createdAt;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  bool isScheduledDuringDnd;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = Priority.medium,
    this.category = TodoCategory.other,
    required this.createdAt,
    this.dueDate,
    this.dueTime,
    this.isScheduledDuringDnd = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    TodoCategory? category,
    DateTime? createdAt,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool? isScheduledDuringDnd,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isScheduledDuringDnd: isScheduledDuringDnd ?? this.isScheduledDuringDnd,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'priority': priority.index,
        'category': category.index,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'dueTimeHour': dueTime?.hour,
        'dueTimeMinute': dueTime?.minute,
        'isScheduledDuringDnd': isScheduledDuringDnd,
      };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        isCompleted: json['isCompleted'],
        priority: Priority.values[json['priority']],
        category: TodoCategory.values[json['category']],
        createdAt: DateTime.parse(json['createdAt']),
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        dueTime: json['dueTimeHour'] != null
            ? TimeOfDay(hour: json['dueTimeHour'], minute: json['dueTimeMinute'])
            : null,
        isScheduledDuringDnd: json['isScheduledDuringDnd'] ?? false,
      );

  Color get priorityColor {
    switch (priority) {
      case Priority.high:
        return const Color(0xFFFF4757);
      case Priority.medium:
        return const Color(0xFFFF9F43);
      case Priority.low:
        return const Color(0xFF2ED573);
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case TodoCategory.work:
        return Icons.work_rounded;
      case TodoCategory.personal:
        return Icons.person_rounded;
      case TodoCategory.health:
        return Icons.favorite_rounded;
      case TodoCategory.study:
        return Icons.school_rounded;
      case TodoCategory.other:
        return Icons.star_rounded;
    }
  }

  String get categoryName {
    switch (category) {
      case TodoCategory.work:
        return 'Work';
      case TodoCategory.personal:
        return 'Personal';
      case TodoCategory.health:
        return 'Health';
      case TodoCategory.study:
        return 'Study';
      case TodoCategory.other:
        return 'Other';
    }
  }
}
