import 'package:flutter_test/flutter_test.dart';
import 'package:tunathic/core/music_theory/chord_symbol_parser.dart';
import 'package:tunathic/core/music_theory/pitch_class.dart';
import 'package:tunathic/features/repertoire/domain/auto_scroll_speed.dart';
import 'package:tunathic/features/repertoire/domain/chord_pro_parser.dart';
import 'package:tunathic/features/repertoire/domain/chord_sheet_importer.dart';
import 'package:tunathic/features/repertoire/domain/song.dart';
import 'package:tunathic/features/repertoire/domain/song_chord_editor.dart';
import 'package:tunathic/features/repertoire/domain/song_sheet.dart';

void main() {
  group('written chord symbols', () {
    test('keeps suffixes the chord quality model does not cover', () {
      for (final symbol in const [
        'A7sus4',
        'C(add9)',
        'F#m7b5',
        'Gsus2',
        'Bbmaj7',
        'E5',
        'Caug',
        'D°',
      ]) {
        expect(
          ChordSymbolParser.tryParseWritten(symbol)?.symbol,
          symbol,
          reason: symbol,
        );
      }
    });

    test('reads slash chords', () {
      final chord = ChordSymbolParser.tryParseWritten('D/F#');
      expect(chord?.root.symbol, 'D');
      expect(chord?.bass?.symbol, 'F#');
      expect(chord?.symbol, 'D/F#');
    });

    test('rejects ordinary words that start with a note letter', () {
      for (final word in const [
        'Ama',
        'Bende',
        'Gel',
        'Can',
        'Cam',
        'Adam',
        'Bir',
        'Ah',
        'Dedim',
        'Do',
        'Bu',
        'Add',
      ]) {
        expect(ChordSymbolParser.tryParseWritten(word), isNull, reason: word);
      }
    });

    test('transposes the root and the slash bass but not the suffix', () {
      final chord = ChordSymbolParser.tryParseWritten('D7sus4/F#')!;
      final transposed = chord.transpose(
        2,
        preference: SpellingPreference.sharps,
      );
      expect(transposed.symbol, 'E7sus4/G#');
    });
  });

  group('ChordPro parsing', () {
    test('attaches each chord to the fragment it precedes', () {
      final sheet = ChordProParser.parse('[Am]start here and [F]land there');
      final line = sheet.lines.single;

      expect(line.kind, SongLineKind.lyrics);
      expect(line.hasChords, isTrue);
      expect(line.segments.first.chord?.text, 'Am');
      expect(line.segments.first.lyrics, 'start here and ');
      expect(line.segments.last.chord?.text, 'F');
      expect(line.lyrics, 'start here and land there');
    });

    test('keeps blank lines and reads comment directives as headings', () {
      final sheet = ChordProParser.parse(
        '{comment: Intro}\n\n{start_of_tab}\n[C]a line of placeholder words',
      );

      expect(sheet.lines[0].kind, SongLineKind.section);
      expect(sheet.lines[0].label, 'Intro');
      expect(sheet.lines[1].kind, SongLineKind.blank);
      expect(sheet.lines[2].kind, SongLineKind.lyrics);
      expect(sheet.lines.length, 3);
    });

    test('treats a lone non-chord bracket as a section heading', () {
      final sheet = ChordProParser.parse('[Chorus]');

      expect(sheet.lines.single.kind, SongLineKind.section);
      expect(sheet.lines.single.label, 'Chorus');
    });

    test('reports the chords used in the chart once each', () {
      final sheet = ChordProParser.parse(
        '[C]one [G]two [C]three\n[Am]four [F]five',
      );

      expect(sheet.chordSymbols, ['C', 'G', 'Am', 'F']);
    });
  });

  group('sheet transposition', () {
    test('moves every chord by the requested semitones', () {
      final sheet = ChordProParser.parse(
        '[C]one [Am]two [F]three [G]four',
      ).transpose(2);

      expect(sheet.chordSymbols, ['D', 'Bm', 'G', 'A']);
    });

    test('picks one accidental style for the whole chart', () {
      final sheet = ChordProParser.parse(
        '[C]one [Am]two [F]three [G]four',
      ).transpose(1);

      // C transposed up a semitone reads as Db major, so the chart uses flats
      // instead of mixing C# with A#m.
      expect(sheet.chordSymbols, ['Db', 'Bbm', 'Gb', 'Ab']);
    });

    test('honours an explicit accidental choice', () {
      final source = ChordProParser.parse('[C]one [Am]two');

      expect(source.transpose(1, spelling: SheetSpelling.sharps).chordSymbols, [
        'C#',
        'A#m',
      ]);
      expect(source.transpose(2, spelling: SheetSpelling.flats).chordSymbols, [
        'D',
        'Bm',
      ]);
    });

    test('leaves lyrics and non-chord brackets alone', () {
      final sheet = ChordProParser.parse(
        '[Chorus]\n[C]a placeholder lyric line',
      ).transpose(3);

      expect(sheet.lines.first.kind, SongLineKind.section);
      expect(sheet.lines.first.label, 'Chorus');
      expect(sheet.lines.last.lyrics, 'a placeholder lyric line');
      // C up three semitones reads as Eb major, so the chart uses flats.
      expect(sheet.chordSymbols, ['Eb']);
    });
  });

  group('source positions', () {
    test('records where each chord and lyric fragment sits', () {
      const content = '[C]first placeholder line\nsecond placeholder line';
      final sheet = ChordProParser.parse(content);

      final chord = sheet.lines.first.segments.first.chord!;
      expect(content.substring(chord.sourceStart, chord.sourceEnd), '[C]');
      expect(sheet.lines.first.segments.first.lyricsOffset, 3);
      expect(
        sheet.lines.last.segments.first.lyricsOffset,
        content.indexOf('second'),
      );
    });

    test('stays correct across carriage returns', () {
      const content = '[C]one placeholder\r\n[G]two placeholder';
      final sheet = ChordProParser.parse(content);

      final second = sheet.lines.last.segments.first.chord!;
      expect(content.substring(second.sourceStart, second.sourceEnd), '[G]');
      expect(sheet.lines.last.segments.first.lyrics, 'two placeholder');
    });

    test('survives transposition, which never rewrites the text', () {
      const content = '[C]one placeholder line';
      final original = ChordProParser.parse(content);
      final moved = original.transpose(2);

      final chord = moved.lines.single.segments.single.chord!;
      expect(chord.text, 'D');
      expect(content.substring(chord.sourceStart, chord.sourceEnd), '[C]');
    });
  });

  group('chord editing', () {
    test('inserts a bracket at the requested offset', () {
      expect(
        SongChordEditor.insert('placeholder line', offset: 12, chord: 'Am'),
        'placeholder [Am]line',
      );
    });

    test('replaces and removes an existing bracket', () {
      const content = '[C]placeholder line';
      final chord = ChordProParser.parse(
        content,
      ).lines.single.segments.single.chord!;

      expect(
        SongChordEditor.replace(
          content,
          start: chord.sourceStart,
          end: chord.sourceEnd,
          chord: 'Am',
        ),
        '[Am]placeholder line',
      );
      expect(
        SongChordEditor.remove(
          content,
          start: chord.sourceStart,
          end: chord.sourceEnd,
        ),
        'placeholder line',
      );
    });

    test('ignores empty chords and impossible spans', () {
      const content = 'placeholder line';

      expect(SongChordEditor.insert(content, offset: 0, chord: '  '), content);
      expect(
        SongChordEditor.replace(content, start: 5, end: 2, chord: 'C'),
        content,
      );
      expect(SongChordEditor.remove(content, start: 0, end: 999), content);
    });

    test('clamps an offset past the end of the text', () {
      expect(
        SongChordEditor.insert('short', offset: 999, chord: 'C'),
        'short[C]',
      );
    });

    test('produces text the parser reads back as a chord', () {
      const content = 'first placeholder line';
      final edited = SongChordEditor.insert(content, offset: 6, chord: 'Gm');

      final sheet = ChordProParser.parse(edited);
      expect(sheet.chordSymbols, ['Gm']);
      expect(sheet.lines.single.lyrics, content);
    });
  });

  group('plain chart import', () {
    test('moves chords onto the syllable written underneath', () {
      const chart = 'C         G\nthis line has words below';

      expect(ChordSheetImporter.looksLikePlainChordSheet(chart), isTrue);
      expect(
        ChordSheetImporter.convert(chart),
        '[C]this line [G]has words below',
      );
    });

    test('appends chords that sit past the end of a short line', () {
      const chart = 'C      G\nshort';

      expect(ChordSheetImporter.convert(chart), '[C]short[G]');
    });

    test('keeps an instrumental chord line on its own', () {
      const chart = 'Am  F  C  G\n\nthe next placeholder line';

      expect(
        ChordSheetImporter.convert(chart),
        '[Am] [F] [C] [G]\n\nthe next placeholder line',
      );
    });

    test('accepts bar and repeat markers on a chord line', () {
      expect(ChordSheetImporter.isChordLine('| Am | F | x2'), isTrue);
      expect(ChordSheetImporter.isChordLine('Am F C G'), isTrue);
    });

    test('does not mistake lyrics for chords', () {
      for (final line in const [
        'ama bende gel',
        'Ama Bende Gel',
        'Am I early or late',
        'a plain placeholder line',
      ]) {
        expect(ChordSheetImporter.isChordLine(line), isFalse, reason: line);
      }
    });

    test('leaves text that already uses bracket chords untouched', () {
      const source = '[C]already written as ChordPro';

      expect(ChordSheetImporter.looksLikePlainChordSheet(source), isFalse);
      expect(ChordSheetImporter.normalize(source), source);
    });

    test('produces a sheet whose chords survive transposition', () {
      const chart = 'D         A\nthe placeholder line under chords';

      final sheet = ChordProParser.parse(
        ChordSheetImporter.normalize(chart),
      ).transpose(2);

      expect(sheet.chordSymbols, ['E', 'B']);
      expect(sheet.lines.single.lyrics, 'the placeholder line under chords');
    });
  });

  group('auto-scroll speed', () {
    test('maps each level to a steady rate', () {
      expect(AutoScrollSpeed.pixelsPerSecond(1), 8);
      expect(AutoScrollSpeed.pixelsPerSecond(3), 24);
      expect(AutoScrollSpeed.pixelsPerSecond(10), 80);
    });

    test('clamps levels outside the supported range', () {
      expect(AutoScrollSpeed.pixelsPerSecond(0), 8);
      expect(AutoScrollSpeed.pixelsPerSecond(99), 80);
    });

    test('advances by the elapsed time and stops at the end', () {
      expect(
        AutoScrollSpeed.advance(
          offset: 100,
          elapsed: const Duration(seconds: 1),
          level: 5,
          maxOffset: 1000,
        ),
        140,
      );
      expect(
        AutoScrollSpeed.advance(
          offset: 990,
          elapsed: const Duration(seconds: 2),
          level: 5,
          maxOffset: 1000,
        ),
        1000,
      );
    });
  });

  group('song storage model', () {
    test('round-trips through JSON', () {
      final song = Song(
        id: 'song-1',
        title: 'Placeholder title',
        artist: 'Placeholder artist',
        content: '[C]a placeholder line',
        transpose: -2,
        scrollSpeedLevel: 7,
        updatedAt: DateTime.utc(2026, 8, 4, 12),
      );

      final restored = Song.fromJson(song.toJson())!;

      expect(restored.id, song.id);
      expect(restored.title, song.title);
      expect(restored.artist, song.artist);
      expect(restored.content, song.content);
      expect(restored.transpose, -2);
      expect(restored.scrollSpeedLevel, 7);
      expect(restored.updatedAt, song.updatedAt);
    });

    test('rejects entries without an id or title', () {
      expect(Song.fromJson({'title': 'No id'}), isNull);
      expect(Song.fromJson({'id': 'song-1'}), isNull);
      expect(Song.fromJson('not a song'), isNull);
    });

    test('clamps stored values that are out of range', () {
      final song = Song.fromJson({
        'id': 'song-1',
        'title': 'Placeholder title',
        'transpose': 40,
        'scrollSpeedLevel': 0,
      })!;

      expect(song.transpose, Song.maxTranspose);
      expect(song.scrollSpeedLevel, Song.minScrollSpeedLevel);
    });
  });
}
