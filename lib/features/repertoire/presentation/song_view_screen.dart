import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/core/music_theory/chord_symbol_parser.dart';
import 'package:tunathic/core/screen/screen_wake_lock.dart';
import 'package:tunathic/features/repertoire/application/repertoire_controller.dart';
import 'package:tunathic/features/repertoire/domain/auto_scroll_speed.dart';
import 'package:tunathic/features/repertoire/domain/chord_pro_parser.dart';
import 'package:tunathic/features/repertoire/domain/song.dart';
import 'package:tunathic/features/repertoire/domain/song_chord_editor.dart';
import 'package:tunathic/features/repertoire/domain/song_sheet.dart';
import 'package:tunathic/features/repertoire/presentation/chord_picker_sheet.dart';
import 'package:tunathic/features/repertoire/presentation/song_sheet_view.dart';
import 'package:tunathic/l10n/app_localizations.dart';

/// The performance view: transpose by semitone and scroll hands-free.
final class SongViewScreen extends ConsumerStatefulWidget {
  const SongViewScreen({
    super.key,
    required this.songId,
    this.startInChordEditing = false,
  });

  final String songId;

  /// Opens straight into chord placement, used right after lyrics are written.
  final bool startInChordEditing;

  @override
  ConsumerState<SongViewScreen> createState() => _SongViewScreenState();
}

class _SongViewScreenState extends ConsumerState<SongViewScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final Ticker _ticker;
  late final ScreenWakeLock _wakeLock;

  Duration _lastTick = Duration.zero;
  bool _scrolling = false;
  bool _restored = false;
  late bool _editingChords = widget.startInChordEditing;
  int _transpose = 0;
  int _speedLevel = Song.defaultScrollSpeedLevel;
  SheetSpelling _spelling = SheetSpelling.auto;

  @override
  void initState() {
    super.initState();
    // Created eagerly: a lazy ticker would be built during dispose, when the
    // TickerMode ancestor can no longer be looked up.
    _ticker = createTicker(_onTick);
    // Read here rather than in dispose, where the ref is no longer usable. A
    // performer reads this screen without touching the device, so the display
    // stays on for as long as the sheet is open.
    _wakeLock = ref.read(screenWakeLockProvider);
    unawaited(_wakeLock.enable());
  }

  @override
  void dispose() {
    unawaited(_wakeLock.disable());
    _ticker
      ..stop()
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final songs = ref.watch(repertoireProvider).value;
    final song = songs == null ? null : _findSong(songs);
    if (song != null && !_restored) {
      _restored = true;
      _transpose = song.transpose;
      _speedLevel = song.scrollSpeedLevel;
    }

    if (song == null) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.repertoire)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Text(
              songs == null
                  ? localizations.repertoire
                  : localizations.pageNotFoundDescription,
            ),
          ),
        ),
      );
    }

    final sheet = ChordProParser.parse(
      song.content,
    ).transpose(_transpose, spelling: _spelling);

    return Scaffold(
      appBar: AppBar(
        title: Text(song.title),
        actions: [
          IconButton(
            key: const Key('toggleChordEditing'),
            tooltip: _editingChords
                ? localizations.doneEditingChords
                : localizations.editChords,
            onPressed: sheet.isEmpty ? null : _toggleChordEditing,
            icon: Icon(_editingChords ? Icons.done : Icons.edit_note),
          ),
          IconButton(
            key: const Key('editSong'),
            tooltip: localizations.editSong,
            onPressed: () {
              _stopScrolling();
              context.push(AppRoutes.repertoireSongEditor(song.id));
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: AppSpacing.small),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: Column(
              children: [
                if (_editingChords)
                  _ChordEditingBanner(
                    localizations: localizations,
                    onDone: _toggleChordEditing,
                  )
                else
                  _PerformanceControls(
                    localizations: localizations,
                    transpose: _transpose,
                    speedLevel: _speedLevel,
                    spelling: _spelling,
                    scrolling: _scrolling,
                    onTransposeBy: (delta) =>
                        _setTranspose(song, _transpose + delta),
                    onTransposeReset: () => _setTranspose(song, 0),
                    onSpelling: (value) => setState(() => _spelling = value),
                    onSpeed: (value) => _setSpeed(song, value),
                    onToggleScroll: _toggleScrolling,
                  ),
                Expanded(
                  child: NotificationListener<ScrollStartNotification>(
                    // A performer taking over by hand stops the auto-scroll.
                    onNotification: (notification) {
                      if (notification.dragDetails != null) _stopScrolling();
                      return false;
                    },
                    child: SingleChildScrollView(
                      key: const Key('songSheetScroll'),
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.medium,
                        AppSpacing.small,
                        AppSpacing.medium,
                        AppSpacing.xxLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (song.artist.isNotEmpty) ...[
                            Text(
                              song.artist,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.small),
                          ],
                          if (sheet.chordSymbols.isNotEmpty) ...[
                            Text(
                              '${localizations.songChordsLabel}: '
                              '${sheet.chordSymbols.join('  ')}',
                              key: const Key('songChordSummary'),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                          ],
                          if (sheet.isEmpty)
                            Text(
                              localizations.emptySongContent,
                              style: Theme.of(context).textTheme.bodyLarge,
                            )
                          else
                            SongSheetView(
                              sheet: sheet,
                              onSelectWord: _editingChords
                                  ? (target) => _placeChord(song, sheet, target)
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Song? _findSong(List<Song> songs) {
    for (final song in songs) {
      if (song.id == widget.songId) return song;
    }
    return null;
  }

  void _setTranspose(Song song, int value) {
    final clamped = Song.clampTranspose(value);
    if (clamped == _transpose) return;
    unawaited(ref.read(appHapticsProvider).selection());
    setState(() => _transpose = clamped);
    unawaited(
      ref.read(repertoireProvider.notifier).setTranspose(song.id, clamped),
    );
  }

  void _setSpeed(Song song, int level) {
    final clamped = Song.clampScrollSpeedLevel(level);
    if (clamped == _speedLevel) return;
    setState(() => _speedLevel = clamped);
    unawaited(
      ref
          .read(repertoireProvider.notifier)
          .setScrollSpeedLevel(song.id, clamped),
    );
  }

  void _toggleChordEditing() {
    unawaited(ref.read(appHapticsProvider).selection());
    _stopScrolling();
    setState(() => _editingChords = !_editingChords);
  }

  /// Places, replaces, or removes the chord on the tapped word.
  ///
  /// The picker offers what the performer currently sees, so a chart being read
  /// transposed has the chosen chord converted back to the written key before
  /// it is stored.
  Future<void> _placeChord(
    Song song,
    SongSheet sheet,
    SheetChordTarget target,
  ) async {
    final existing = target.chord;
    final result = await ChordPickerSheet.show(
      context,
      word: target.word,
      currentChord: existing?.text,
      songChords: sheet.chordSymbols,
    );
    if (result == null || !mounted) return;

    var content = song.content;
    switch (result) {
      case ChordChosen(:final symbol):
        final written = _writtenSymbol(symbol);
        content = existing == null
            ? SongChordEditor.insert(
                song.content,
                offset: target.offset,
                chord: written,
              )
            : SongChordEditor.replace(
                song.content,
                start: existing.sourceStart,
                end: existing.sourceEnd,
                chord: written,
              );
      case ChordCleared():
        if (existing == null) return;
        content = SongChordEditor.remove(
          song.content,
          start: existing.sourceStart,
          end: existing.sourceEnd,
        );
    }
    if (content == song.content) return;

    unawaited(ref.read(appHapticsProvider).lightImpact());
    await ref.read(repertoireProvider.notifier).setContent(song.id, content);
  }

  /// Converts a chord the performer sees back into the song's written key.
  String _writtenSymbol(String displayed) {
    if (_transpose == 0) return displayed;
    final parsed = ChordSymbolParser.tryParseWritten(displayed);
    return parsed == null ? displayed : parsed.transpose(-_transpose).symbol;
  }

  void _toggleScrolling() {
    unawaited(ref.read(appHapticsProvider).selection());
    if (_scrolling) {
      _stopScrolling();
      return;
    }
    setState(() => _scrolling = true);
    _lastTick = Duration.zero;
    _ticker.start();
  }

  void _stopScrolling() {
    if (!_scrolling) return;
    _ticker.stop();
    setState(() => _scrolling = false);
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastTick;
    _lastTick = elapsed;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final next = AutoScrollSpeed.advance(
      offset: position.pixels,
      elapsed: delta,
      level: _speedLevel,
      maxOffset: position.maxScrollExtent,
    );
    _scrollController.jumpTo(next);
    if (next >= position.maxScrollExtent) _stopScrolling();
  }
}

final class _ChordEditingBanner extends StatelessWidget {
  const _ChordEditingBanner({
    required this.localizations,
    required this.onDone,
  });

  final AppLocalizations localizations;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.small,
        AppSpacing.medium,
        AppSpacing.small,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.small),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.xSmall,
          children: [
            Icon(
              Icons.touch_app_outlined,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                localizations.editChordsHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            FilledButton.tonal(
              key: const Key('doneEditingChords'),
              onPressed: onDone,
              child: Text(localizations.doneEditingChords),
            ),
          ],
        ),
      ),
    );
  }
}

final class _PerformanceControls extends StatelessWidget {
  const _PerformanceControls({
    required this.localizations,
    required this.transpose,
    required this.speedLevel,
    required this.spelling,
    required this.scrolling,
    required this.onTransposeBy,
    required this.onTransposeReset,
    required this.onSpelling,
    required this.onSpeed,
    required this.onToggleScroll,
  });

  final AppLocalizations localizations;
  final int transpose;
  final int speedLevel;
  final SheetSpelling spelling;
  final bool scrolling;
  final ValueChanged<int> onTransposeBy;
  final VoidCallback onTransposeReset;
  final ValueChanged<SheetSpelling> onSpelling;
  final ValueChanged<int> onSpeed;
  final VoidCallback onToggleScroll;

  static const _sliderWidth = 220.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.small,
        AppSpacing.medium,
        AppSpacing.small,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.small),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wrap rather than Row: at large text scales these controls have to
            // fall onto extra runs instead of overflowing.
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xSmall,
              runSpacing: AppSpacing.xSmall,
              children: [
                Text(
                  localizations.transposeLabel,
                  style: theme.textTheme.labelLarge,
                ),
                IconButton.filledTonal(
                  key: const Key('transposeDown'),
                  tooltip: localizations.transposeDown,
                  onPressed: transpose > Song.minTranspose
                      ? () => onTransposeBy(-1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.minTouchTarget,
                  ),
                  child: Semantics(
                    label: localizations.transposeSemitones(transpose),
                    child: ExcludeSemantics(
                      child: Text(
                        transpose > 0 ? '+$transpose' : '$transpose',
                        key: const Key('transposeValue'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  key: const Key('transposeUp'),
                  tooltip: localizations.transposeUp,
                  onPressed: transpose < Song.maxTranspose
                      ? () => onTransposeBy(1)
                      : null,
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  key: const Key('transposeReset'),
                  tooltip: localizations.transposeReset,
                  onPressed: transpose == 0 ? null : onTransposeReset,
                  icon: const Icon(Icons.restart_alt),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<SheetSpelling>(
                key: const Key('accidentalStyle'),
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: SheetSpelling.auto,
                    label: Text(localizations.accidentalAuto),
                  ),
                  ButtonSegment(
                    value: SheetSpelling.sharps,
                    label: Text(localizations.accidentalSharps),
                  ),
                  ButtonSegment(
                    value: SheetSpelling.flats,
                    label: Text(localizations.accidentalFlats),
                  ),
                ],
                selected: {spelling},
                onSelectionChanged: (selection) => onSpelling(selection.first),
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.xSmall,
              children: [
                // The action verb stays in the tooltip and the semantics label
                // so the button itself keeps a short, stable width.
                Tooltip(
                  message: scrolling
                      ? localizations.stopAutoScroll
                      : localizations.startAutoScroll,
                  child: FilledButton.tonalIcon(
                    key: const Key('autoScrollToggle'),
                    onPressed: onToggleScroll,
                    icon: Icon(scrolling ? Icons.pause : Icons.play_arrow),
                    label: Text(localizations.autoScroll),
                  ),
                ),
                SizedBox(
                  width: _sliderWidth,
                  child: Semantics(
                    label: localizations.scrollSpeed,
                    value: localizations.scrollSpeedValue(
                      speedLevel,
                      Song.maxScrollSpeedLevel,
                    ),
                    child: Slider(
                      key: const Key('scrollSpeedSlider'),
                      value: speedLevel.toDouble(),
                      min: Song.minScrollSpeedLevel.toDouble(),
                      max: Song.maxScrollSpeedLevel.toDouble(),
                      divisions:
                          Song.maxScrollSpeedLevel - Song.minScrollSpeedLevel,
                      label: '$speedLevel',
                      onChanged: (value) => onSpeed(value.round()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
