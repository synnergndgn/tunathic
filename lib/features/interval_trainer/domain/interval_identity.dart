enum IntervalIdentity {
  perfectUnison(1, 0),
  minorSecond(2, 1),
  majorSecond(2, 2),
  minorThird(3, 3),
  majorThird(3, 4),
  perfectFourth(4, 5),
  augmentedFourth(4, 6),
  diminishedFifth(5, 6),
  perfectFifth(5, 7),
  minorSixth(6, 8),
  majorSixth(6, 9),
  minorSeventh(7, 10),
  majorSeventh(7, 11),
  perfectOctave(8, 12);

  const IntervalIdentity(this.diatonicNumber, this.semitones);

  final int diatonicNumber;
  final int semitones;

  bool get isTritone =>
      this == IntervalIdentity.augmentedFourth ||
      this == IntervalIdentity.diminishedFifth;
}

enum IntervalDifficulty {
  beginner,
  intermediate,
  advanced;

  List<IntervalIdentity> get identities => switch (this) {
    IntervalDifficulty.beginner => const [
      IntervalIdentity.perfectUnison,
      IntervalIdentity.minorSecond,
      IntervalIdentity.majorSecond,
      IntervalIdentity.majorThird,
      IntervalIdentity.perfectFourth,
      IntervalIdentity.perfectFifth,
      IntervalIdentity.perfectOctave,
    ],
    IntervalDifficulty.intermediate => const [
      IntervalIdentity.perfectUnison,
      IntervalIdentity.minorSecond,
      IntervalIdentity.majorSecond,
      IntervalIdentity.minorThird,
      IntervalIdentity.majorThird,
      IntervalIdentity.perfectFourth,
      IntervalIdentity.perfectFifth,
      IntervalIdentity.minorSixth,
      IntervalIdentity.majorSixth,
      IntervalIdentity.minorSeventh,
      IntervalIdentity.majorSeventh,
      IntervalIdentity.perfectOctave,
    ],
    IntervalDifficulty.advanced => IntervalIdentity.values,
  };
}
