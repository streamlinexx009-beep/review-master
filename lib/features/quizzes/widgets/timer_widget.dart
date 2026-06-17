import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget
    extends StatefulWidget {

  final int seconds;

  final VoidCallback onComplete;

  const TimerWidget({
    super.key,
    required this.seconds,
    required this.onComplete,
  });

  @override
  State<TimerWidget>
      createState() =>
          _TimerWidgetState();
}

class _TimerWidgetState
    extends State<TimerWidget> {

  late int remaining;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    remaining =
        widget.seconds;

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {

        if (remaining <= 0) {
          widget.onComplete();
          timer.cancel();
        }

        setState(() {
          remaining--;
        });
      },
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Text(
      '$remaining sec',
    );
  }
}