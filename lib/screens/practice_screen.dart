import 'package:flutter/material.dart';

import '../app.dart';
import '../practice_controller.dart';
import '../widgets.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.state});
  final AppState state;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final PracticeController _controller = PracticeController();
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();
  bool _stored = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() async {
    setState(() {});
    if (_controller.isFinished && !_stored) {
      _stored = true;
      await widget.state.addRecord(_controller.finishRecord(DateTime.now()));
      if (mounted) _showFinishedDialog();
    }
  }

  void _showFinishedDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('本段完成'),
        content: Text(
          '速度 ${_controller.speed.toStringAsFixed(2)} 字/分\n用时 ${formatDuration(_controller.elapsed)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('查看记录'),
          ),
        ],
      ),
    );
  }

  void _retry() {
    _controller.retry();
    _inputController.clear();
    _stored = false;
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final controller = _controller;
      return PageContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              paused: controller.status == PracticeStatus.paused,
              canToggle:
                  controller.status == PracticeStatus.typing ||
                  controller.status == PracticeStatus.paused,
              onPause: controller.togglePause,
            ),
            const SizedBox(height: 14),
            MetricCard(
              leftValue: controller.speed.toStringAsFixed(2),
              leftLabel: '字/分',
              rightValue: formatDuration(controller.elapsed),
              rightLabel: '用时',
            ),
            const SizedBox(height: 16),
            _Progress(
              current: controller.progress,
              total: controller.target.length,
            ),
            const SizedBox(height: 16),
            OutlinePanel(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '对照文本',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(
                        Icons.volume_up_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TargetRichText(
                    target: controller.target,
                    input: controller.input,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.yellow,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  '当前词语：轻轻  qiyi',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.warning),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    controller.isFinished ? '已完成' : '正在输入',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    enabled:
                        controller.status != PracticeStatus.paused &&
                        !controller.isFinished,
                    onChanged: controller.updateInput,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '点击这里开始跟打',
                    ),
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontFamily: 'serif',
                      fontSize: 20,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.status == PracticeStatus.paused
                      ? '练习已暂停'
                      : '系统输入法已就绪',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                FilledButton.icon(
                  onPressed: _retry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.soft,
                    foregroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('重打'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinePanel(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  _SmallMetric(
                    label: '速度',
                    value: controller.speed.toStringAsFixed(2),
                  ),
                  _SmallMetric(
                    label: '回改',
                    value: '${controller.replacements}',
                  ),
                  _SmallMetric(label: '字数', value: '${controller.progress}'),
                  _SmallMetric(label: '打词', value: '0'),
                  _SmallMetric(label: '错字', value: '${controller.errors}'),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.paused,
    required this.canToggle,
    required this.onPause,
  });
  final bool paused;
  final bool canToggle;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton.outlined(onPressed: null, icon: const Icon(Icons.arrow_back)),
      const Column(
        children: [
          Text(
            '自由文本跟打',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          Text(
            '当前练习',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      IconButton.filled(
        onPressed: canToggle ? onPause : null,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
        ),
        icon: Icon(paused ? Icons.play_arrow : Icons.pause),
      ),
    ],
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '练习进度',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          Text(
            '$current / $total',
            style: const TextStyle(
              color: AppColors.primary,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: total == 0 ? 0 : current / total,
          minHeight: 6,
          color: AppColors.primary,
          backgroundColor: AppColors.soft,
        ),
      ),
    ],
  );
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.ink,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

class _TargetRichText extends StatelessWidget {
  const _TargetRichText({required this.target, required this.input});
  final String target;
  final String input;

  static const _correctBg = Color(0xFFe5e5e5);
  static const _errorBg = Color(0xFFF56C6C);
  static const _typedFg = Color(0xFF000000);
  static const _errorFg = Color(0xFF000000);
  static const _pendingFg = Color(0xFF606266);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: _pendingFg,
          fontFamily: 'serif',
          fontSize: 22,
          height: 1.7,
        ),
        children: List.generate(target.length, (i) {
          if (i >= input.length) {
            return TextSpan(text: target[i]);
          }
          final correct = input[i] == target[i];
          return TextSpan(
            text: target[i],
            style: TextStyle(
              color: correct ? _typedFg : _errorFg,
              backgroundColor: correct ? _correctBg : _errorBg,
            ),
          );
        }),
      ),
    );
  }
}
