import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

import '../widgets/btmnavbar.dart';
import 'timer_basic.dart';
import 'timer_frame.dart';

class CustomTimer extends StatefulWidget {
  const CustomTimer({super.key});

  @override
  State<CustomTimer> createState() => _CustomTimerState();
}

class _CustomTimerState extends State<CustomTimer> {
  late bool _isPaused;
  late bool _isStopped;
  late bool _timerStarted;
  late int _lapCount;
  late CountDownController _controller;
  late Duration _selectedDuration;

  @override
  void initState() {
    super.initState();
    _isPaused = false;
    _isStopped = true;
    _timerStarted = false;
    _lapCount = 0;
    _selectedDuration = const Duration(hours: 1);
    _controller = CountDownController(
      duration: _selectedDuration,
      onTick: (duration) {
        print('Remaining Time: $duration');
      },
      onComplete: () {
        _stopTimer();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isStopped ? () => _selectTime(context) : null,
              child: Text(
                'Pick Time: ${_selectedDuration.inHours}:${(_selectedDuration.inMinutes.remainder(60)).toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TimerFrame(
                description: 'FIT GEEK TIMER',
                timer: TimerBasic(
                  format: CountDownTimerFormat.hoursMinutesSeconds,
                  controller: _controller,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _timerStarted
                      ? (_isPaused ? _resumeTimer : _pauseTimer)
                      : () => _startTimer(),
                  child: Text(_isPaused ? 'Resume' : 'SET'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _timerStarted ? _stopTimer : null,
                  child: const Text('Start Again'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _timerStarted ? _lap : null,
                  child: const Text('Lap'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_lapCount > 0)
              Text(
                'Lap $_lapCount complete',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BtmNavBar(
        currentIndex: 1,
        onItemSelected: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      // Handle navigation item tap here
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(DateTime.now().add(_selectedDuration)),
    );
    if (pickedTime != null) {
      final Duration newDuration =
          Duration(hours: pickedTime.hour, minutes: pickedTime.minute);
      setState(() {
        _selectedDuration = newDuration;
        if (_timerStarted) {
          _controller.duration = newDuration;
        } else {
          _controller = CountDownController(
            duration: newDuration,
            onTick: (duration) {},
            onComplete: () {
              _stopTimer();
            },
          );
          _startTimer();
        }
      });
    }
  }

  void _startTimer() {
    _controller.start();
    setState(() {
      _isStopped = false;
      _timerStarted = true;
    });
  }

  void _pauseTimer() {
    _controller.pause();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    _controller.resume();
    setState(() {
      _isPaused = false;
    });
  }

  void _stopTimer() {
    _controller.stop();
    setState(() {
      _isPaused = false;
      _isStopped = true;
      _timerStarted = false;
      _lapCount = 0;
    });
  }

  void _lap() {
    setState(() {
      _lapCount++;
    });
  }
}

class CountDownController {
  late Timer _countdownTimer;
  late Duration _duration;
  late Duration _remainingTime;
  late bool _isPaused = false;
  late bool _isStopped = true;
  late Function(Duration) _onTick;
  late Function _onComplete;

  CountDownController({
    required Duration duration,
    required Function(Duration) onTick,
    required Function onComplete,
  }) {
    _duration = duration;
    _remainingTime = duration;
    _onTick = onTick;
    _onComplete = onComplete;
  }

  set duration(Duration value) {
    _duration = value;
    _remainingTime = value;
  }

  Duration get remainingTime => _remainingTime;

  void start() {
    if (!_isStopped) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingTime = _remainingTime - const Duration(seconds: 1);
      _onTick(_remainingTime);
      if (_remainingTime <= Duration.zero) {
        stop();
        _onComplete();
      }
    });
    _isStopped = false;
    _isPaused = false;
  }

  void pause() {
    if (_isPaused || _isStopped) return;
    _countdownTimer.cancel();
    _isPaused = true;
  }

  void resume() {
    if (!_isPaused || _isStopped) return;
    start();
    _isPaused = false;
  }

  void stop() {
    _countdownTimer.cancel();
    _remainingTime = _duration;
    _isPaused = false;
    _isStopped = true;
  }
}
