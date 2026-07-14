import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';

import 'support/fakes.dart';

void main() {
  test('enabled haptics forward selection and impact requests', () async {
    final output = FakeHapticFeedbackOutput();
    final haptics = AppHaptics(isEnabled: () => true, output: output);

    await haptics.selection();
    await haptics.lightImpact();

    expect(output.selectionCount, 1);
    expect(output.lightImpactCount, 1);
  });

  test('disabled haptics suppress all platform requests', () async {
    final output = FakeHapticFeedbackOutput();
    final haptics = AppHaptics(isEnabled: () => false, output: output);

    await haptics.selection();
    await haptics.lightImpact();

    expect(output.selectionCount, 0);
    expect(output.lightImpactCount, 0);
  });
}
