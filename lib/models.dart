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
