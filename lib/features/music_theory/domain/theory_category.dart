/// The nine top-level sections of the Music Theory hub.
///
/// The declaration order is the browsing order, which runs from the smallest
/// building block (single notes) to instrument-specific application.
enum TheoryCategory {
  musicalNotes('musical-notes'),
  intervals('intervals'),
  chords('chords'),
  scales('scales'),
  circleOfFifths('circle-of-fifths'),
  fretboardTheory('fretboard-theory'),
  rhythm('rhythm'),
  harmony('harmony'),
  guitarTheory('guitar-theory');

  const TheoryCategory(this.id);

  final String id;

  static TheoryCategory? fromId(String? id) {
    for (final category in values) {
      if (category.id == id) return category;
    }
    return null;
  }
}
