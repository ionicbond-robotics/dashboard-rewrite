import 'dart:async';

import 'package:flutter/material.dart';

class TimelineView extends StatefulWidget {
  final double incrementValue;
  final double maxValue;

  TimelineView({
    required this.incrementValue,
    required this.maxValue,
  });

  @override
  _TimelineViewState createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  double _currentValue = 0.0;
  bool _isPlaying = false;
  Timer? _timer;

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 1000 ~/ 60), (timer) {
      setState(() {
        _currentValue += widget.incrementValue;
        if (_currentValue >= widget.maxValue) {
          _currentValue = widget.maxValue;
          _isPlaying = false;
          _stopTimer();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Slider(
          value: _currentValue,
          min: 0.0,
          max: widget.maxValue,
          onChanged: (value) {
            setState(() {
              _currentValue = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: _togglePlayPause,
            ),
            Text(
              _isPlaying ? 'Pause' : 'Play',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}
