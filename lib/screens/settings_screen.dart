import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../models.dart';
import '../widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late List<String> _fields;

  @override
  void initState() {
    super.initState();
    _fields = [...widget.state.resultFormat.fields];
  }

  String get _preview {
    final values = <String>['第248段', '速度86.00', '击键0.00', '码长0.00'];
    const optional = {
      'replace': '回改4',
      'contentLength': '字数100',
      'phraseRate': '打词率0%',
      'error': '错字0',
      'retry': '重打0',
    };
    for (final field in _fields) {
      values.add(optional[field]!);
    }
    return values.join(' ');
  }

  Future<void> _save() async {
    await widget.state.updateFormat(ResultFormatSettings(fields: _fields));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('发送格式已保存')));
  }

  @override
  Widget build(BuildContext context) => PageContent(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '设置',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.soft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '成绩完成后可复制以下格式。段号、速度、击键和码长为固定字段。',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '成绩发送格式',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '实时预览',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '发送内容',
                style: TextStyle(
                  color: Color(0xFFBFD0C1),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _preview,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinePanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const _FixedRow(value: '第xx段'),
              const _FixedRow(value: '速度123.00'),
              const _FixedRow(value: '击键0.00'),
              const _FixedRow(value: '码长0.00'),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorderItem: (oldIndex, newIndex) => setState(() {
                  final field = _fields.removeAt(oldIndex);
                  _fields.insert(newIndex, field);
                }),
                children: _fields
                    .map(
                      (field) => _OptionalRow(
                        key: ValueKey(field),
                        field: field,
                        enabled: true,
                        onToggle: () => setState(() => _fields.remove(field)),
                      ),
                    )
                    .toList(),
              ),
              ..._hidden.map(
                (field) => _OptionalRow(
                  key: ValueKey(field),
                  field: field,
                  enabled: false,
                  onToggle: () => setState(() => _fields.add(field)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.save_outlined),
          label: const Text('保存发送格式'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: _preview));
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('预览已复制')));
            }
          },
          icon: const Icon(Icons.content_copy),
          label: const Text('复制预览'),
        ),
      ],
    ),
  );

  Iterable<String> get _hidden => const [
    'replace',
    'contentLength',
    'phraseRate',
    'error',
    'retry',
  ].where((field) => !_fields.contains(field));
}

class _FixedRow extends StatelessWidget {
  const _FixedRow({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) => _SettingRow(
    icon: Icons.lock_outline,
    value: value,
    subtitle: '固定字段',
    iconColor: AppColors.primary,
  );
}

class _OptionalRow extends StatelessWidget {
  const _OptionalRow({
    super.key,
    required this.field,
    required this.enabled,
    required this.onToggle,
  });
  final String field;
  final bool enabled;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) {
    const labels = {
      'replace': '回改4',
      'contentLength': '字数100',
      'phraseRate': '打词率0%',
      'error': '错字0',
      'retry': '重打0',
    };
    return _SettingRow(
      icon: enabled ? Icons.drag_indicator : Icons.visibility_off_outlined,
      value: labels[field]!,
      subtitle: enabled ? '可隐藏 · 长按拖动排序' : '点击显示字段',
      iconColor: enabled ? AppColors.muted : AppColors.muted,
      trailing: IconButton(
        onPressed: onToggle,
        icon: Icon(
          enabled ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.value,
    required this.subtitle,
    required this.iconColor,
    this.trailing,
  });
  final IconData icon;
  final String value;
  final String subtitle;
  final Color iconColor;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Container(
    height: 53,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
        ),
        ...(trailing == null ? const <Widget>[] : <Widget>[trailing!]),
      ],
    ),
  );
}
