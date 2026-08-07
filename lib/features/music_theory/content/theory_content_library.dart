import 'package:tunathic/features/music_theory/content/theory_content_en.dart';
import 'package:tunathic/features/music_theory/content/theory_content_tr.dart';
import 'package:tunathic/features/music_theory/domain/theory_content.dart';

/// Selects lesson content for the active language.
///
/// English is the source language and the fallback, matching the app's
/// locale resolution.
abstract final class TheoryContentLibrary {
  static const supported = <TheoryContent>[theoryContentEn, theoryContentTr];

  static TheoryContent forLanguageCode(String? languageCode) =>
      switch (languageCode) {
        'tr' => theoryContentTr,
        _ => theoryContentEn,
      };
}
