import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../models.dart';
import '../widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.state});
  final AppState state;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _range = 7;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.state,
    builder: (context, _) {
      final records = _filtered(widget.state.records);
      final average = records.isEmpty
          ? 0.0
          : records.fold<double>(0, (sum, record) => sum + record.speed) /
                records.length;
      final days = records
          .map((record) => DateUtils.dateOnly(record.finishedAt))
          .toSet()
          .length;
      final totalWords = records.fold<int>(
        0,
        (sum, record) => sum + record.contentLength,
      );
      final replacements = records.fold<int>(
        0,
        (sum, record) => sum + record.replacements,
      );
      return PageContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '练习统计',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _RangeControl(
              selected: _range,
              onSelected: (value) => setState(() => _range = value),
            ),
            const SizedBox(height: 16),
            MetricCard(
              leftValue: average.toStringAsFixed(2),
              leftLabel: '平均速度',
              rightValue: '$days',
              rightLabel: '练习天数',
            ),
            const SizedBox(height: 18),
            _TrendChart(records: records),
            const SizedBox(height: 18),
            const Text(
              '记录概览',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            OutlinePanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _StatRow(label: '累计字数', value: '$totalWords 字'),
                  const Divider(height: 1, color: AppColors.border),
                  const _StatRow(label: '累计打词', value: '0 字'),
                  const Divider(height: 1, color: AppColors.border),
                  _StatRow(label: '累计回改', value: '$replacements 次'),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  List<PracticeRecord> _filtered(List<PracticeRecord> records) {
    if (_range == 0) return records;
    final cutoff = DateTime.now().subtract(Duration(days: _range));
    return records
        .where((record) => record.finishedAt.isAfter(cutoff))
        .toList();
  }
}

class _RangeControl extends StatelessWidget {
  const _RangeControl({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.soft,
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.all(4),
    child: Row(
      children: [
        _RangeButton(
          label: '7 天',
          active: selected == 7,
          onTap: () => onSelected(7),
        ),
        _RangeButton(
          label: '30 天',
          active: selected == 30,
          onTap: () => onSelected(30),
        ),
        _RangeButton(
          label: '全部',
          active: selected == 0,
          onTap: () => onSelected(0),
        ),
      ],
    ),
  );
}

class _RangeButton extends StatelessWidget {
  const _RangeButton({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.muted,
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.records});
  final List<PracticeRecord> records;
  @override
  Widget build(BuildContext context) {
    final data = records.take(7).toList().reversed.toList();
    return OutlinePanel(
      child: SizedBox(
        height: 224,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '速度趋势',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '字/分',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: data.isEmpty
                  ? const Center(
                      child: Text(
                        '完成练习后显示趋势',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        barGroups: List.generate(
                          data.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: data[index].speed,
                                color: index == data.length - 1
                                    ? AppColors.primary
                                    : AppColors.soft,
                                width: 22,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.ink,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}
