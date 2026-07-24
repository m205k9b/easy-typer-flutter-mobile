import 'package:easy_typer_flutter/practice_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PracticeController', () {
    test('starts, compares input and records corrections', () {
      final controller = PracticeController(target: '春风雨');

      controller.updateInput('春');
      expect(controller.status, PracticeStatus.typing);
      controller.updateInput('春雨');
      expect(controller.progress, 2);
      expect(controller.errors, 1);

      controller.updateInput('春');
      expect(controller.replacements, 1);
      expect(controller.errors, 0);
      controller.dispose();
    });

    test('finishes only after the complete target is entered', () {
      final controller = PracticeController(title: '测试', target: '春风');

      controller.updateInput('春');
      expect(controller.isFinished, isFalse);
      controller.updateInput('春风');

      expect(controller.isFinished, isTrue);
      final record = controller.finishRecord(DateTime(2026, 7, 23));
      expect(record.title, '测试');
      expect(record.contentLength, 2);
      expect(record.errors, 0);
      controller.dispose();
    });

    test('retries reset current results and retain retry count', () {
      final controller = PracticeController(target: '春风');
      controller.updateInput('春');

      controller.retry();

      expect(controller.status, PracticeStatus.ready);
      expect(controller.input, isEmpty);
      expect(controller.elapsed, Duration.zero);
      expect(controller.retries, 1);
      controller.dispose();
    });
  });
}
