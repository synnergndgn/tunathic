import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tunathic/app/router/app_router.dart';
import 'package:tunathic/app/theme/app_spacing.dart';
import 'package:tunathic/core/haptics/app_haptics.dart';
import 'package:tunathic/features/repertoire/application/repertoire_controller.dart';
import 'package:tunathic/features/repertoire/domain/song.dart';
import 'package:tunathic/l10n/app_localizations.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_button.dart';
import 'package:tunathic/shared/widgets/studio/skeuo_surface.dart';

/// Lists the songs stored on this device.
final class RepertoireScreen extends ConsumerStatefulWidget {
  const RepertoireScreen({super.key});

  @override
  ConsumerState<RepertoireScreen> createState() => _RepertoireScreenState();
}

class _RepertoireScreenState extends ConsumerState<RepertoireScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final songs = ref.watch(repertoireProvider);
    final haptics = ref.read(appHapticsProvider);

    void openEditor(String? songId) {
      unawaited(haptics.selection());
      context.push(
        songId == null
            ? AppRoutes.repertoireNewSong
            : AppRoutes.repertoireSongEditor(songId),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(localizations.repertoire)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addSong'),
        onPressed: () => openEditor(null),
        icon: const Icon(Icons.add),
        label: Text(localizations.addSong),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: songs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Text(localizations.unexpectedErrorDescription),
              ),
              data: (songs) => songs.isEmpty
                  ? _EmptyRepertoire(
                      localizations: localizations,
                      onAdd: () => openEditor(null),
                    )
                  : _SongList(
                      songs: _filter(songs),
                      searchController: _searchController,
                      localizations: localizations,
                      onQueryChanged: (value) => setState(() => _query = value),
                      onOpen: (song) {
                        unawaited(haptics.selection());
                        context.push(AppRoutes.repertoireSong(song.id));
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  List<Song> _filter(List<Song> songs) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return songs;
    return [
      for (final song in songs)
        if (song.title.toLowerCase().contains(query) ||
            song.artist.toLowerCase().contains(query))
          song,
    ];
  }
}

final class _SongList extends StatelessWidget {
  const _SongList({
    required this.songs,
    required this.searchController,
    required this.localizations,
    required this.onQueryChanged,
    required this.onOpen,
  });

  final List<Song> songs;
  final TextEditingController searchController;
  final AppLocalizations localizations;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Song> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('repertoireScroll'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.xxLarge,
      ),
      children: [
        TextField(
          key: const Key('songSearchField'),
          controller: searchController,
          onChanged: onQueryChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: localizations.searchSongs,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        if (songs.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Text(
              localizations.noMatchingSongs,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        for (final song in songs)
          SkeuoCard(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              key: Key('song-${song.id}'),
              title: Text(song.title),
              subtitle: song.artist.isEmpty ? null : Text(song.artist),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpen(song),
            ),
          ),
      ],
    );
  }
}

final class _EmptyRepertoire extends StatelessWidget {
  const _EmptyRepertoire({required this.localizations, required this.onAdd});

  final AppLocalizations localizations;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      key: const Key('repertoireScroll'),
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        const SizedBox(height: AppSpacing.large),
        Icon(
          Icons.library_books_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.medium),
        Semantics(
          header: true,
          child: Text(
            localizations.repertoireEmptyTitle,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          localizations.repertoireEmptyDescription,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.large),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SkeuoButton(
            key: const Key('addFirstSong'),
            onPressed: onAdd,
            selected: true,
            icon: Icons.add,
            child: Text(localizations.addSong),
          ),
        ),
      ],
    );
  }
}
