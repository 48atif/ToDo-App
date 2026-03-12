import 'package:flutter/material.dart';
import '../models/dnd_schedule.dart';

class DndBanner extends StatefulWidget {
  final DndSchedule? schedule;
  final bool isManual;
  const DndBanner({super.key, this.schedule, required this.isManual});

  @override
  State<DndBanner> createState() => _DndBannerState();
}

class _DndBannerState extends State<DndBanner> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 4, 20, 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(_pulseAnimation.value),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF).withOpacity(_pulseAnimation.value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isManual
                          ? 'Do Not Disturb — Manual'
                          : 'Do Not Disturb — ${widget.schedule?.name ?? "Scheduled"}',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (!widget.isManual && widget.schedule != null)
                      Text(
                        widget.schedule!.timeRangeString,
                        style: TextStyle(
                          color: const Color(0xFF6C63FF).withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.do_not_disturb_on,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
