import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

import 'timer.dart';

class TimerBasic extends StatelessWidget {
  final CountDownTimerFormat format;
  final CountDownController controller;

  const TimerBasic({
    super.key,
    required this.format,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final initialTime =
        now.add(controller.remainingTime); // Use remainingTime getter method

    return TimerCountdown(
      format: format,
      endTime: initialTime,
      timeTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w300,
        fontSize: 40,
        fontFeatures: <FontFeature>[
          FontFeature.tabularFigures(),
        ],
      ),
      colonsTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w300,
        fontSize: 40,
        fontFeatures: <FontFeature>[
          FontFeature.tabularFigures(),
        ],
      ),
      descriptionTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontFeatures: <FontFeature>[
          FontFeature.tabularFigures(),
        ],
      ),
      spacerWidth: 0,
      daysDescription: "days",
      hoursDescription: "hours",
      minutesDescription: "minutes",
      secondsDescription: "seconds",
    );
  }
}
