import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../models.dart';
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

  Future<void> _loadFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final raw = data?.text ?? '';
    if (raw.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('剪贴板为空')),
      );
      return;
    }
    final article = parseClipboardArticle(raw);
    if (article.content.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未识别到正文内容')),
      );
      return;
    }
    _controller.loadArticle(
      title: article.title,
      target: article.content,
      paragraphNo: article.paragraphNo,
    );
    _inputController.clear();
    _stored = false;
    _focusNode.requestFocus();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已载入：${article.displayTitle}')),
    );
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
              onMenu: () => _showArticleMenu(context),
            ),
            const SizedBox(height: 14),
            _CompactMetric(
              speed: controller.speed,
              elapsed: controller.elapsed,
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
                  _TargetRichText(
                    target: controller.target,
                    input: controller.input,
                  ),
                ],
              ),
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

  void _showArticleMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(20, 80, 320, 0),
      items: const [
        PopupMenuItem(value: 'clipboard', child: Text('从剪贴板载入文章')),
      ],
    ).then((value) {
      if (value == 'clipboard') _loadFromClipboard();
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.paused,
    required this.canToggle,
    required this.onPause,
    required this.onMenu,
  });
  final bool paused;
  final bool canToggle;
  final VoidCallback onPause;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton.outlined(
        onPressed: onMenu,
        icon: const Icon(Icons.menu),
      ),
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

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({required this.speed, required this.elapsed});
  final double speed;
  final Duration elapsed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Item(
          value: speed.toStringAsFixed(2),
          label: '字/分',
        ),
        _Item(value: formatDuration(elapsed), label: '用时', alignEnd: true),
      ],
    ),
  );
}

class _Item extends StatelessWidget {
  const _Item({required this.value, required this.label, this.alignEnd = false});
  final String value;
  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment:
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Color(0xFFBFD0C1), fontSize: 10)),
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
