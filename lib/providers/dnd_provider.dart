import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/dnd_schedule.dart';

class DndProvider extends ChangeNotifier {
  bool _isDndActive = false;
  bool _isDndManual = false;
  List<DndSchedule> _schedules = [];
  Timer? _checkTimer;
  final _uuid = const Uuid();

  bool get isDndActive => _isDndActive;
  bool get isDndManual => _isDndManual;
  List<DndSchedule> get schedules => _schedules;
  DndSchedule? get activeSchedule =>
      _schedules.where((s) => s.isEnabled && s.isActiveNow()).firstOrNull;

  DndProvider() {
    _loadData();
    _addDefaultSchedules();
    _startTimer();
  }

  void _addDefaultSchedules() {
    if (_schedules.isNotEmpty) return;
    _schedules = [
      DndSchedule(
        id: _uuid.v4(),
        name: 'Sleep Time',
        startTime: const TimeOfDay(hour: 22, minute: 0),
        endTime: const TimeOfDay(hour: 7, minute: 0),
        activeDays: [1, 2, 3, 4, 5, 6, 7],
        isEnabled: true,
        allowUrgentTasks: false,
      ),
      DndSchedule(
        id: _uuid.v4(),
        name: 'Deep Work',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        activeDays: [1, 2, 3, 4, 5],
        isEnabled: false,
        allowUrgentTasks: true,
      ),
    ];
    _saveData();
  }

  void toggleManualDnd() {
    _isDndManual = !_isDndManual;
    _updateDndState();
    notifyListeners();
  }

  void addSchedule(DndSchedule schedule) {
    _schedules.add(schedule);
    _saveData();
    _checkSchedules();
    notifyListeners();
  }

  void updateSchedule(DndSchedule updated) {
    final index = _schedules.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _schedules[index] = updated;
      _saveData();
      _checkSchedules();
      notifyListeners();
    }
  }

  void deleteSchedule(String id) {
    _schedules.removeWhere((s) => s.id == id);
    _saveData();
    _checkSchedules();
    notifyListeners();
  }

  void toggleSchedule(String id) {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index].isEnabled = !_schedules[index].isEnabled;
      _saveData();
      _checkSchedules();
      notifyListeners();
    }
  }

  String createScheduleId() => _uuid.v4();

  void _startTimer() {
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkSchedules();
    });
    _checkSchedules();
  }

  void _checkSchedules() {
    final wasActive = _isDndActive;
    _updateDndState();
    if (wasActive != _isDndActive) {
      notifyListeners();
    }
  }

  void _updateDndState() {
    if (_isDndManual) {
      _isDndActive = true;
      return;
    }
    _isDndActive = _schedules.any((s) => s.isEnabled && s.isActiveNow());
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _schedules.map((s) => s.toJson()).toList();
    await prefs.setString('dnd_schedules', jsonEncode(jsonList));
    await prefs.setBool('dnd_manual', _isDndManual);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('dnd_schedules');
    if (jsonStr != null) {
      final jsonList = jsonDecode(jsonStr) as List;
      _schedules = jsonList.map((j) => DndSchedule.fromJson(j)).toList();
    }
    _isDndManual = prefs.getBool('dnd_manual') ?? false;
    _updateDndState();
    notifyListeners();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
