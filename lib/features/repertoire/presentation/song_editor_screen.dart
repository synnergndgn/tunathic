import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/repertoire/application/repertoire_controller.dart';
import 'package:tunathic/features/repertoire/domain/chord_sheet_importer.dart';
import 'package:tunathic/features/repertoire/domain/song.dart';
import 'package:tunathic/l10n/app_localizations.dart';

/// Creates or edits a song. A pasted chart is converted to ChordPro on save.
final class SongEditorScreen extends ConsumerStatefulWidget {
  const SongEditorScreen({super.key, this.songId});

  final String? songId;

  @override
  ConsumerState<SongEditorScreen> createState() => _SongEditorScreenState();
}

class _SongEditorScreenState extends ConsumerState<SongEditorScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _contentController = TextEditingController();
  bool _prefilled = false;
  bool _titleMissing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final songs = ref.watch(repertoireProvider).value;
    final editing = widget.songId != null;
    final song = editing && songs != null ? _findSong(songs) : null;
    if (song != null) _prefill(song);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing ? localizations.editSongTitle : localizations.newSongTitle,
        ),
        actions: [
          if (editing)
            IconButton(
              key: const Key('deleteSong'),
              tooltip: localizations.deleteSong,
              onPressed: song == null ? null : () => _confirmDelete(song),
              icon: const Icon(Icons.delete_outline),
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
            child: ListView(
              key: const Key('songEditorScroll'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.xLarge,
              ),
              children: [
                TextField(
                  key: const Key('songTitleField'),
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: localizations.songTitleLabel,
                    errorText: _titleMissing
                        ? localizations.songTitleRequired
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  key: const Key('songArtistField'),
                  controller: _artistController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: localizations.songArtistLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  key: const Key('songContentField'),
                  controller: _contentController,
                  minLines: 10,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: localizations.songContentLabel,
                    helperText: localizations.songContentHint,
                    helperMaxLines: 4,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                FilledButton.icon(
                  key: const Key('saveSong'),
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: Text(localizations.saveSong),
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

  void _prefill(Song song) {
    if (_prefilled) return;
    _prefilled = true;
    _titleController.text = song.title;
    _artistController.text = song.artist;
    _contentController.text = song.content;
  }

  Future<void> _save() async {
    final localizations = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleMissing = true);
      return;
    }
    setState(() => _titleMissing = false);

    final content = _contentController.text;
    final converted = ChordSheetImporter.looksLikePlainChordSheet(content);
    final controller = ref.read(repertoireProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    unawaited(ref.read(appHapticsProvider).selection());
    final songId = widget.songId;
    Song? created;
    if (songId == null) {
      created = await controller.create(
        title: title,
        artist: _artistController.text,
        content: content,
      );
    } else {
      await controller.updateDetails(
        id: songId,
        title: title,
        artist: _artistController.text,
        content: content,
      );
    }

    if (!mounted) return;
    if (converted) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizations.chartConverted)),
      );
    }

    // Writing the words first only pays off if the chords come next, so a new
    // song with lyrics opens straight into chord placement. Replacing the
    // editor keeps Android back going to the song list.
    if (created != null && created.content.trim().isNotEmpty) {
      router.pushReplacement(
        AppRoutes.repertoireSong(created.id, editChords: true),
      );
      return;
    }
    if (router.canPop()) router.pop();
  }

  Future<void> _confirmDelete(Song song) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteSong),
        content: Text(localizations.deleteSongPrompt(song.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancelAction),
          ),
          FilledButton(
            key: const Key('confirmDeleteSong'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final router = GoRouter.of(context);
    await ref.read(repertoireProvider.notifier).delete(song.id);
    if (!mounted) return;
    // Both the editor and the performance view below it are now stale.
    router.go(AppRoutes.repertoire);
  }
}
