import 'package:flutter_test/flutter_test.dart';
import 'package:mi_r_r_a_dev/components/feedback_collector/feedback_service.dart';

void main() {
  group('FeedbackService.milestoneDue', () {
    test('пороги — 2, 10, 30, 50', () {
      expect(kFeedbackScanMilestones, [2, 10, 30, 50]);
    });

    test('первый показ — на втором удачном скане, не раньше', () {
      expect(FeedbackService.milestoneDue(lastPromptScans: 0, scans: 0), isFalse);
      expect(FeedbackService.milestoneDue(lastPromptScans: 0, scans: 1), isFalse);
      expect(FeedbackService.milestoneDue(lastPromptScans: 0, scans: 2), isTrue);
    });

    test('после показа ждём следующий порог', () {
      expect(FeedbackService.milestoneDue(lastPromptScans: 2, scans: 2), isFalse);
      expect(FeedbackService.milestoneDue(lastPromptScans: 2, scans: 9), isFalse);
      expect(FeedbackService.milestoneDue(lastPromptScans: 2, scans: 10), isTrue);
      expect(FeedbackService.milestoneDue(lastPromptScans: 10, scans: 29), isFalse);
      expect(FeedbackService.milestoneDue(lastPromptScans: 10, scans: 30), isTrue);
      expect(FeedbackService.milestoneDue(lastPromptScans: 30, scans: 50), isTrue);
    });

    test('пропущенный порог не теряется', () {
      // Показ на 2 не случился — на 3-м скане всё ещё пора.
      expect(FeedbackService.milestoneDue(lastPromptScans: 0, scans: 3), isTrue);
      // Показали на 12-м (порог 10 запоздал) — следующий только на 30.
      expect(FeedbackService.milestoneDue(lastPromptScans: 12, scans: 29), isFalse);
      expect(FeedbackService.milestoneDue(lastPromptScans: 12, scans: 30), isTrue);
    });

    test('после последнего порога больше не спрашиваем', () {
      expect(FeedbackService.milestoneDue(lastPromptScans: 50, scans: 51), isFalse);
      expect(FeedbackService.milestoneDue(lastPromptScans: 50, scans: 500), isFalse);
    });
  });
}
