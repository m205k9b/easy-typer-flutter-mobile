import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class LocalRepository {
  LocalRepository._(this._preferences);

  static const _recordsKey = 'practice_records_v1';
  static const _formatKey = 'result_format_v1';
  final SharedPreferences _preferences;

  static Future<LocalRepository> create() async =>
      LocalRepository._(await SharedPreferences.getInstance());

  List<PracticeRecord> loadRecords() {
    final raw = _preferences.getString(_recordsKey);
    if (raw == null) return [];
    final records = (jsonDecode(raw) as List<dynamic>)
        .map((item) => PracticeRecord.fromJson(item as Map<String, dynamic>))
        .toList();
    records.sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
    return records;
  }

  Future<void> saveRecord(PracticeRecord record) async {
    final records = loadRecords();
    records.removeWhere((item) => item.id == record.id);
    records.insert(0, record);
    await _preferences.setString(
      _recordsKey,
      jsonEncode(records.map((item) => item.toJson()).toList()),
    );
  }

  ResultFormatSettings loadFormat() {
    final raw = _preferences.getString(_formatKey);
    return raw == null
        ? const ResultFormatSettings()
        : ResultFormatSettings.fromJson(
            jsonDecode(raw) as Map<String, dynamic>,
          );
  }

  Future<void> saveFormat(ResultFormatSettings settings) =>
      _preferences.setString(_formatKey, jsonEncode(settings.toJson()));
}
