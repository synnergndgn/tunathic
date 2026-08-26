import 'package:flutter/material.dart';
import 'package:tunathic/app/theme/app_radii.dart';
import 'package:tunathic/app/theme/app_spacing.dart';

/// One highlighted note with the degree it plays in the example.
final class TheoryNoteChipData {
  const TheoryNoteChipData({
    required this.note,
    required this.degree,
    this.isRoot = false,
  });

  final String note;
  final String degree;
  final bool isRoot;
}

/// A wrapping row of note chips.
///
/// Roots are filled so the shape of an example reads at a glance, and the row
/// is announced as one label rather than as a stream of fragments.
final class TheoryNoteChips extends StatelessWidget {
  const TheoryNoteChips({
    required this.notes,
    required this.semanticLabel,
    super.key,
  });

  final List<TheoryNoteChipData> notes;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            for (final note in notes)
              Container(
                constraints: const BoxConstraints(minWidth: 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                  vertical: AppSpacing.small,
                ),
                decoration: BoxDecoration(
                  color: note.isRoot ? colors.primaryContainer : null,
                  border: Border.all(
                    color: note.isRoot ? colors.primary : colors.outlineVariant,
                  ),
                  borderRadius: AppRadii.smallBorder,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      note.note,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: note.isRoot ? colors.onPrimaryContainer : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      note.degree,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: note.isRoot
                            ? colors.onPrimaryContainer
                            : colors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
