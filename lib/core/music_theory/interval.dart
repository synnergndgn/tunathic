enum TheoryInterval {
  perfectUnison('perfect-unison', 0, 0, 'P1'),
  minorSecond('minor-second', 1, 1, 'm2'),
  majorSecond('major-second', 2, 1, 'M2'),
  minorThird('minor-third', 3, 2, 'm3'),
  majorThird('major-third', 4, 2, 'M3'),
  perfectFourth('perfect-fourth', 5, 3, 'P4'),
  augmentedFourth('augmented-fourth', 6, 3, 'A4'),
  diminishedFifth('diminished-fifth', 6, 4, 'd5'),
  perfectFifth('perfect-fifth', 7, 4, 'P5'),
  minorSixth('minor-sixth', 8, 5, 'm6'),
  augmentedFifth('augmented-fifth', 8, 4, 'A5'),
  majorSixth('major-sixth', 9, 5, 'M6'),
  diminishedSeventh('diminished-seventh', 9, 6, 'd7'),
  minorSeventh('minor-seventh', 10, 6, 'm7'),
  majorSeventh('major-seventh', 11, 6, 'M7'),
  octave('octave', 12, 7, 'P8'),
  minorNinth('minor-ninth', 13, 8, 'm9'),
  majorNinth('major-ninth', 14, 8, 'M9'),
  perfectEleventh('perfect-eleventh', 17, 10, 'P11'),
  majorThirteenth('major-thirteenth', 21, 12, 'M13');

  const TheoryInterval(
    this.id,
    this.semitones,
    this.diatonicSteps,
    this.shortLabel,
  );

  final String id;
  final int semitones;
  final int diatonicSteps;
  final String shortLabel;

  int get simpleSemitones => semitones % 12;
}
