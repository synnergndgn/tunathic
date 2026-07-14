import 'package:tunathic/core/logging/app_logger.dart';
import 'package:tunathic/core/preferences/preferences_store.dart';
import 'package:tunathic/features/metronome/domain/metronome_config.dart';

final class MetronomePreferences {
  MetronomePreferences(this._store);

  static const _bpmKey = 'metronome.bpm';
  static const _timeSignatureKey = 'metronome.timeSignature';
  static const _accentEnabledKey = 'metronome.accentEnabled';
  static const _volumeKey = 'metronome.volume';

  final PreferencesStore _store;

  Future<MetronomeConfig> load() async {
    final values = await Future.wait([
      _store.getString(_bpmKey),
      _store.getString(_timeSignatureKey),
      _store.getString(_accentEnabledKey),
      _store.getString(_volumeKey),
    ]);
    final parsedBpm = int.tryParse(values[0] ?? '');
    final parsedVolume = double.tryParse(values[3] ?? '');

    return MetronomeConfig(
      bpm: parsedBpm == null
          ? MetronomeConfig.defaultBpm
          : MetronomeConfig.clampBpm(parsedBpm),
      timeSignature: MetronomeTimeSignature.fromId(values[1]),
      accentEnabled: switch (values[2]) {
        'false' => false,
        _ => true,
      },
      volume: parsedVolume == null
          ? MetronomeConfig.defaultVolume
          : parsedVolume.clamp(0.0, 1.0),
    );
  }

  Future<void> save(MetronomeConfig config) async {
    await Future.wait([
      _store.setString(_bpmKey, config.bpm.toString()),
      _store.setString(_timeSignatureKey, config.timeSignature.id),
      _store.setString(_accentEnabledKey, config.accentEnabled.toString()),
      _store.setString(_volumeKey, config.volume.toString()),
    ]);
  }
}

Future<MetronomeConfig> loadInitialMetronomeConfig(
  PreferencesStore store,
  AppLogger logger,
) async {
  try {
    return await MetronomePreferences(store).load();
  } on Object catch (error, stackTrace) {
    logger.error('Could not load metronome preferences', error, stackTrace);
    return const MetronomeConfig();
  }
}
