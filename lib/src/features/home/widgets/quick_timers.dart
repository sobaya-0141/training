import 'package:flutter/material.dart';
import 'package:kintore/src/features/timer/timer_screen.dart';

class QuickTimers extends StatelessWidget {
  const QuickTimers({super.key});

  static const timers = [('3分', 180), ('10分', 600)];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'クイックタイマー',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final (index, timer) in timers.indexed) ...[
              Expanded(
                child: FilledButton.tonal(
                  key: ValueKey('quick_timer_${timer.$2}_button'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TimerScreen.simple(
                        title: timer.$1,
                        seconds: timer.$2,
                      ),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(timer.$1),
                ),
              ),
              if (index != timers.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}
