class PracticeRecord {
  const PracticeRecord({
    required this.id,
    required this.title,
    required this.contentLength,
    required this.elapsedMilliseconds,
    required this.speed,
    required this.errors,
    required this.replacements,
    required this.retries,
    required this.finishedAt,
  });

  final String id;
  final String title;
  final int contentLength;
  final int elapsedMilliseconds;
  final double speed;
  final int errors;
  final int replacements;
  final int retries;
  final DateTime finishedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'contentLength': contentLength,
    'elapsedMilliseconds': elapsedMilliseconds,
    'speed': speed,
    'errors': errors,
    'replacements': replacements,
    'retries': retries,
    'finishedAt': finishedAt.toIso8601String(),
  };

  factory PracticeRecord.fromJson(Map<String, dynamic> json) => PracticeRecord(
    id: json['id'] as String,
    title: json['title'] as String,
    contentLength: json['contentLength'] as int,
    elapsedMilliseconds: json['elapsedMilliseconds'] as int,
    speed: (json['speed'] as num).toDouble(),
    errors: json['errors'] as int,
    replacements: json['replacements'] as int,
    retries: json['retries'] as int,
    finishedAt: DateTime.parse(json['finishedAt'] as String),
  );
}

class ResultFormatSettings {
  const ResultFormatSettings({
    this.fields = const [
      'replace',
      'contentLength',
      'phraseRate',
      'error',
      'retry',
    ],
  });

  final List<String> fields;

  bool isVisible(String field) => fields.contains(field);

  ResultFormatSettings copyWith({List<String>? fields}) =>
      ResultFormatSettings(fields: fields ?? this.fields);

  Map<String, dynamic> toJson() => {'fields': fields};

  factory ResultFormatSettings.fromJson(Map<String, dynamic> json) =>
      ResultFormatSettings(
        fields: List<String>.from(json['fields'] as List<dynamic>),
      );
}

/// An article parsed from clipboard text.
///
/// Clipboard text used for practice is conventionally split across lines:
///   line 1 - paragraph title
///   line 2 - content to be typed
///   line 3 - paragraph metadata, prefixed by five dashes (`-----`) and the
///            paragraph number (e.g. `第89471段`).
class ClipboardArticle {
  const ClipboardArticle({
    required this.title,
    required this.content,
    this.paragraphNo = '',
  });

  final String title;
  final String content;
  final String paragraphNo;

  /// A display title combining the paragraph title and number.
  String get displayTitle =>
      paragraphNo.isEmpty ? title : '$title $paragraphNo';
}

/// Parses a multi-line clipboard snippet into a [ClipboardArticle].
///
/// Falls back to using the whole trimmed text as the content when the snippet
/// does not contain any newlines.
ClipboardArticle parseClipboardArticle(String raw) {
  final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) {
    return const ClipboardArticle(title: '', content: '');
  }
  if (lines.length == 1) {
    return ClipboardArticle(title: '', content: lines.first.trim());
  }
  final title = lines.first.trim();
  final content = lines[1].trim();
  var paragraphNo = '';
  if (lines.length >= 3) {
    final meta = lines[2].trim();
    final tail = meta.startsWith('-----') ? meta.substring(5).trim() : meta;
    if (tail.isNotEmpty) {
      paragraphNo = tail.split('-').first.trim();
    }
  }
  return ClipboardArticle(
    title: title,
    content: content,
    paragraphNo: paragraphNo,
  );
}
