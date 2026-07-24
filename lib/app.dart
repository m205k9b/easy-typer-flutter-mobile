import 'package:flutter/material.dart';

import 'data/local_repository.dart';
import 'models.dart';
import 'screens/practice_screen.dart';
import 'screens/records_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository)
    : records = repository.loadRecords(),
      resultFormat = repository.loadFormat();

  final LocalRepository repository;
  List<PracticeRecord> records;
  ResultFormatSettings resultFormat;

  Future<void> addRecord(PracticeRecord record) async {
    await repository.saveRecord(record);
    records = repository.loadRecords();
    notifyListeners();
  }

  Future<void> updateFormat(ResultFormatSettings settings) async {
    resultFormat = settings;
    await repository.saveFormat(settings);
    notifyListeners();
  }
}

class EasyTyperApp extends StatefulWidget {
  const EasyTyperApp({super.key, required this.repository});

  final LocalRepository repository;

  @override
  State<EasyTyperApp> createState() => _EasyTyperAppState();
}

class _EasyTyperAppState extends State<EasyTyperApp> {
  late final AppState _state = AppState(widget.repository);

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: '易跟打',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      fontFamily: 'sans-serif',
    ),
    home: AppShell(state: _state),
  );
}

class AppColors {
  static const background = Color(0xFFF5F3EE);
  static const ink = Color(0xFF173426);
  static const primary = Color(0xFF2D5E3A);
  static const soft = Color(0xFFDDE8DC);
  static const border = Color(0xFFC9D5C9);
  static const muted = Color(0xFF688072);
  static const warning = Color(0xFFC95A47);
  static const yellow = Color(0xFFE7C76A);
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.state});

  final AppState state;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      PracticeScreen(state: widget.state),
      RecordsScreen(state: widget.state),
      StatisticsScreen(state: widget.state),
      SettingsScreen(state: widget.state),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xF2FFFFFF),
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A173426),
                blurRadius: 18,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavigationItem(
                  icon: Icons.home_outlined,
                  label: '练习',
                  active: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavigationItem(
                  icon: Icons.history,
                  label: '记录',
                  active: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavigationItem(
                  icon: Icons.bar_chart_outlined,
                  label: '统计',
                  active: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
                _NavigationItem(
                  icon: Icons.settings_outlined,
                  label: '设置',
                  active: _index == 3,
                  onTap: () => setState(() => _index = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? AppColors.soft : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? AppColors.primary : AppColors.muted,
              size: 21,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.primary : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
