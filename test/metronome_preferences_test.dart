import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/features/metronome/application/metronome_preferences.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

import 'support/fakes.dart';

void main() {
  test('loads persisted metronome preferences', () async {
    final store = MemoryPreferencesStore({
      'metronome.bpm': '96',
      'metronome.timeSignature': '6/8',
      'metronome.accentEnabled': 'false',
      'metronome.volume': '0.4',
    });

    final config = await MetronomePreferences(store).load();

    expect(config.bpm, 96);
    expect(config.timeSignature, MetronomeTimeSignature.sixEight);
    expect(config.accentEnabled, isFalse);
    expect(config.volume, 0.4);
  });

  test('safely defaults and clamps invalid persisted values', () async {
    final store = MemoryPreferencesStore({
      'metronome.bpm': '900',
      'metronome.timeSignature': '7/13',
      'metronome.accentEnabled': 'unknown',
      'metronome.volume': '-2',
    });

    final config = await MetronomePreferences(store).load();

    expect(config.bpm, 300);
    expect(config.timeSignature, MetronomeTimeSignature.fourFour);
    expect(config.accentEnabled, isTrue);
    expect(config.volume, 0);
  });

  test('saves only valuable metronome preferences', () async {
    final store = MemoryPreferencesStore();
    const config = MetronomeConfig(
      bpm: 144,
      timeSignature: MetronomeTimeSignature.threeFour,
      accentEnabled: false,
      volume: 0.75,
    );

    await MetronomePreferences(store).save(config);

    expect(store.values, {
      'metronome.bpm': '144',
      'metronome.timeSignature': '3/4',
      'metronome.accentEnabled': 'false',
      'metronome.volume': '0.75',
    });
  });
}
