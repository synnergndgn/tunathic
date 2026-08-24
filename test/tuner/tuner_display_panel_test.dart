import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/app/theme/app_theme.dart';
import 'package:tunathic/app/theme/studio_theme.dart';
import 'package:tunathic/features/tuner/presentation/widgets/tuner_display_panel.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

void main() {
  testWidgets('signal changes never restyle the tuner frame or containers', (
    tester,
  ) async {
    for (final signal in StudioSignal.values) {
      await tester.pumpWidget(_app(signal));

      expect(
        tester.widget<SkeuoSurface>(find.byType(SkeuoSurface)).accent,
        null,
      );
      expect(
        tester.widgetList<SkeuoDisplayPanel>(find.byType(SkeuoDisplayPanel)),
        everyElement(
          isA<SkeuoDisplayPanel>().having(
            (panel) => panel.accent,
            'accent',
            isNull,
          ),
        ),
      );
      expect(find.byType(StudioCornerBrackets), findsNothing);
    }
  });
}

Widget _app(StudioSignal signal) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: TunerDisplayPanel(
        signal: signal,
        noteName: 'A',
        octave: 4,
        cents: 0,
        centsText: '+0 cents',
        noteSemantics: 'A4',
        centsSemantics: 'in tune',
        frequencyText: '440.0 Hz',
        frequencySemantics: '440 hertz',
        referenceText: 'A4 = 440 Hz',
        referenceSemantics: 'reference 440 hertz',
        targetText: '5 · A2',
        targetSemantics: 'target A2',
        flatLabel: 'Flat',
        inTuneLabel: 'In tune',
        sharpLabel: 'Sharp',
      ),
    ),
  );
}
