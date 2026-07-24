import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../models.dart';
import '../widgets.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: state,
    builder: (context, _) {
      final records = state.records;
      final best = records.fold<double>(
        0,
        (value, record) => record.speed > value ? record.speed : value,
      );
      final totalWords = records.fold<int>(
        0,
        (value, record) => value + record.contentLength,
      );
      return PageContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '练习记录',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '共 ${records.length} 次自由文本跟打',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                IconButton.outlined(
                  onPressed: () {},
                  icon: const Icon(Icons.tune, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MetricCard(
              leftValue: best.toStringAsFixed(2),
              leftLabel: '最佳速度',
              rightValue: NumberFormat.decimalPattern().format(totalWords),
              rightLabel: '累计字数',
            ),
            const SizedBox(height: 18),
            const Text(
              '今天',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            if (records.isEmpty)
              const _RecordsEmpty()
            else
              ...records.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecordCard(record: record),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _RecordsEmpty extends StatelessWidget {
  const _RecordsEmpty();
  @override
  Widget build(BuildContext context) => OutlinePanel(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const Icon(
            Icons.history_toggle_off,
            color: AppColors.muted,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            '还没有练习记录',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '完成一段自由文本跟打后会显示在这里',
            style: TextStyle(
              color: AppColors.muted.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});
  final PracticeRecord record;

  @override
  Widget build(BuildContext context) => OutlinePanel(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            record.id.substring(record.id.length - 3),
            style: const TextStyle(
              color: AppColors.primary,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${formatDuration(Duration(milliseconds: record.elapsedMilliseconds))}  ·  ${record.contentLength} 字',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              record.speed.toStringAsFixed(2),
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const Text(
              '字/分',
              style: TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );
}
