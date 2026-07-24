import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models.dart';

enum PracticeStatus { ready, typing, paused, finished }

class PracticeController extends ChangeNotifier {
  PracticeController({
    this.title = '当前练习',
    this.target = '春天的风轻轻掠过窗台，带来一阵新叶的清香。街角的树枝上，细小的花苞正在慢慢舒展。',
  });

  String title;
  String target;
  String input = '';
  PracticeStatus status = PracticeStatus.ready;
  Duration elapsed = Duration.zero;
  int replacements = 0;
  int retries = 0;
  Timer? _timer;

  int get errors => List<int>.generate(
    input.length,
    (index) => index,
  ).where((index) => input[index] != target[index]).length;
  int get progress => input.length.clamp(0, target.length).toInt();
  double get speed => elapsed.inMilliseconds == 0
      ? 0
      : progress *
            const Duration(minutes: 1).inMilliseconds /
            elapsed.inMilliseconds;
  bool get isFinished => status == PracticeStatus.finished;

  void updateInput(String value) {
    final sanitized = value.length > target.length
        ? value.substring(0, target.length)
        : value;
    if (status == PracticeStatus.paused || status == PracticeStatus.finished) {
      return;
    }
    if (sanitized.isNotEmpty && status == PracticeStatus.ready) {
      _start();
    }
    if (sanitized.length < input.length) {
      replacements += input.length - sanitized.length;
    }
    input = sanitized;
    if (input.length == target.length) {
      _finish();
    }
    notifyListeners();
  }

  void togglePause() {
    if (status == PracticeStatus.typing) {
      status = PracticeStatus.paused;
      _timer?.cancel();
    } else if (status == PracticeStatus.paused) {
      status = PracticeStatus.typing;
      _beginTimer();
    }
    notifyListeners();
  }

  void retry() {
    _timer?.cancel();
    input = '';
    elapsed = Duration.zero;
    replacements = 0;
    status = PracticeStatus.ready;
    retries++;
    notifyListeners();
  }

  PracticeRecord finishRecord(DateTime now) => PracticeRecord(
    id: now.microsecondsSinceEpoch.toString(),
    title: title,
    contentLength: target.length,
    elapsedMilliseconds: elapsed.inMilliseconds,
    speed: speed,
    errors: errors,
    replacements: replacements,
    retries: retries,
    finishedAt: now,
  );

  void _start() {
    status = PracticeStatus.typing;
    _beginTimer();
  }

  void _beginTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      elapsed += const Duration(milliseconds: 100);
      notifyListeners();
    });
  }

  void _finish() {
    status = PracticeStatus.finished;
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
