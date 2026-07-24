import 'package:flutter/material.dart';

import 'app.dart';

class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
    child: child,
  );
}

class OutlinePanel extends StatelessWidget {
  const OutlinePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.leftValue,
    required this.leftLabel,
    required this.rightValue,
    required this.rightLabel,
  });
  final String leftValue;
  final String leftLabel;
  final String rightValue;
  final String rightLabel;

  @override
  Widget build(BuildContext context) => Container(
    height: 88,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Metric(value: leftValue, label: leftLabel),
        _Metric(value: rightValue, label: rightLabel, alignEnd: true),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    this.alignEnd = false,
  });
  final String value;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(color: Color(0xFFBFD0C1), fontSize: 11),
      ),
    ],
  );
}

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  final centiseconds = (duration.inMilliseconds.remainder(1000) ~/ 10)
      .toString()
      .padLeft(2, '0');
  return '$minutes:$seconds.$centiseconds';
}
