const chordContentEn = <String, String>{
  'triads.title': 'Triads',
  'triads.summary':
      'Three notes, a root with a third and a fifth above it, make a chord.',
  'triads.keywords': 'triad, major, minor, root third fifth, 1 3 5, chord',
  'triads.p1':
      'A triad is the smallest complete chord: a root, a third, and a fifth. '
      'The third decides whether it sounds major or minor, and the fifth holds '
      'the chord steady.',
  'triads.exampleMajor': 'C major, a root with a major third and perfect fifth',
  'triads.exampleMinor': 'A minor, the same shape with the third lowered',
  'triads.p2':
      'Diminished and augmented triads change the fifth as well. Diminished '
      'lowers it and sounds unstable; augmented raises it and sounds like it '
      'is stretching upward. Both are less common than major and minor, but '
      'both appear inside ordinary keys.',
  'triads.b1':
      'Major is 1, 3, 5. Minor is 1, flat 3, 5. Only one note changes.',
  'triads.b2':
      'Most open guitar chords repeat their three notes across six strings '
      'rather than adding new ones.',
  'triads.b3':
      'Every chord in this category is a triad with something added or '
      'altered.',
  'triads.fretboard': 'C major across the first five frets',

  'seventh-chords.title': 'Seventh Chords',
  'seventh-chords.summary':
      'A fourth note added a seventh above the root, adding colour or pull.',
  'seventh-chords.keywords':
      'seventh, maj7, m7, dominant seventh, 7, four note chord',
  'seventh-chords.p1':
      'Add one more third on top of a triad and you get a seventh chord. '
      'Which seventh you add changes everything: a major seventh sounds lush '
      'and calm, a minor seventh sounds bluesy, and a dominant seventh sounds '
      'like it needs to move somewhere.',
  'seventh-chords.example': 'G7, the dominant seventh of C major',
  'seventh-chords.p2':
      'The dominant seventh is the most powerful of the three because it '
      'contains a tritone. That tritone is unstable, and resolving it is what '
      'makes a V7 to I progression feel like an ending.',
  'seventh-chords.b1':
      'maj7 is 1 3 5 7, dominant 7 is 1 3 5 flat 7, and m7 is 1 flat 3 5 flat '
      '7.',
  'seventh-chords.b2':
      'A minor seventh flat five, written m7b5, is the seventh chord built on '
      'the leading tone of a major key.',
  'seventh-chords.b3':
      'On guitar you can drop the fifth from a seventh chord and it still '
      'sounds complete.',

  'suspended-chords.title': 'Suspended Chords',
  'suspended-chords.summary':
      'Replace the third with a second or a fourth and the chord loses its '
      'gender.',
  'suspended-chords.keywords': 'sus, sus2, sus4, suspended, no third, open',
  'suspended-chords.p1':
      'A suspended chord removes the third, the note that makes a chord major '
      'or minor, and puts a second or a fourth in its place. The result sounds '
      'open and unresolved rather than happy or sad.',
  'suspended-chords.example': 'Dsus4, with G replacing the F sharp',
  'suspended-chords.p2':
      'Suspensions are usually a moment rather than a destination. Playing '
      'Dsus4 and then D is one of the most recognisable moves on the guitar '
      'because the ear waits for the third to arrive.',
  'suspended-chords.b1': 'sus2 is 1, 2, 5. sus4 is 1, 4, 5.',
  'suspended-chords.b2':
      'A sus chord is neither major nor minor, so it fits over both.',
  'suspended-chords.b3':
      'On open D and A shapes, one finger lifted or added gives you the '
      'suspension instantly.',

  'augmented-chords.title': 'Augmented Chords',
  'augmented-chords.summary':
      'A major triad with the fifth raised, restless and symmetrical.',
  'augmented-chords.keywords':
      'augmented, aug, plus, sharp five, #5, whole tone',
  'augmented-chords.p1':
      'An augmented triad is a major chord with its fifth raised one '
      'semitone. It contains two stacked major thirds, which makes it '
      'perfectly symmetrical and gives it a floating, unsettled sound.',
  'augmented-chords.example': 'C augmented, with G sharp instead of G',
  'augmented-chords.p2':
      'Because the shape repeats every four semitones, one augmented chord '
      'serves as three. It is most often used as a passing chord, where the '
      'raised fifth climbs to the next chord tone.',
  'augmented-chords.b1': 'Augmented is 1, 3, sharp 5.',
  'augmented-chords.b2':
      'Caug, Eaug, and G sharp aug all contain the same three notes.',
  'augmented-chords.b3':
      'Try it between I and vi: C, Caug, Am gives a smooth rising line.',

  'diminished-chords.title': 'Diminished Chords',
  'diminished-chords.summary':
      'Stacked minor thirds: tense chords that want to resolve.',
  'diminished-chords.keywords':
      'diminished, dim, dim7, half diminished, m7b5, flat five',
  'diminished-chords.p1':
      'A diminished triad lowers both the third and the fifth. Add a '
      'diminished seventh and every note sits three semitones from the next, '
      'making another perfectly symmetrical chord.',
  'diminished-chords.example':
      'Bm7b5, the chord on the seventh degree of C '
      'major',
  'diminished-chords.p2':
      'Half diminished, written m7b5, is the everyday one: it is the ii chord '
      'of every minor key. Fully diminished sevenths are used for dramatic '
      'transitions, because any of their four notes can act as the root.',
  'diminished-chords.b1':
      'Diminished triad is 1, flat 3, flat 5. Diminished seventh adds a '
      'double flat 7.',
  'diminished-chords.b2':
      'A diminished seventh shape repeats every three frets.',
  'diminished-chords.b3':
      'm7b5 to V7 to i is the standard opening of a minor key progression.',

  'extended-chords.title': 'Extended Chords',
  'extended-chords.summary':
      'Ninths, elevenths, and thirteenths stacked above a seventh chord.',
  'extended-chords.keywords':
      'extended, 9, 11, 13, add9, tensions, upper structure, jazz',
  'extended-chords.p1':
      'Keep stacking thirds above a seventh chord and you reach the ninth, '
      'eleventh, and thirteenth. These notes are the same as the second, '
      'fourth, and sixth, just written an octave higher because they sit above '
      'the seventh.',
  'extended-chords.example':
      'Cmaj9, a major seventh chord with the ninth '
      'added',
  'extended-chords.p2':
      'Six strings cannot hold six notes comfortably, so guitarists leave '
      'notes out. The root and fifth are the first to go, because the third '
      'and seventh carry the chord\'s identity and the extension carries its '
      'colour.',
  'extended-chords.b1':
      'add9 adds the ninth without a seventh; 9 includes the seventh.',
  'extended-chords.b2':
      'On a dominant chord the eleventh is usually raised, because a natural '
      'eleventh clashes with the major third.',
  'extended-chords.b3':
      'A 13 chord in practice is usually root, third, seventh, and thirteenth.',

  'chord-inversions.title': 'Inversions',
  'chord-inversions.summary':
      'The same chord with a different note in the bass.',
  'chord-inversions.keywords':
      'inversion, slash chord, bass note, first inversion, second inversion, '
      'c/e',
  'chord-inversions.p1':
      'An inversion keeps every note of a chord but changes which one is '
      'lowest. C major with E in the bass is first inversion, written C/E; '
      'with G in the bass it is second inversion, written C/G.',
  'chord-inversions.example':
      'C major, whose three notes can each sit in the '
      'bass',
  'chord-inversions.b1':
      'Root position has the root lowest, first inversion the third, second '
      'inversion the fifth.',
  'chord-inversions.b2':
      'A seventh chord has a third inversion too, with the seventh in the '
      'bass.',
  'chord-inversions.b3':
      'Slash notation names the chord, then the bass note after the slash.',
  'chord-inversions.p2':
      'Inversions exist to smooth the bass line. Moving from C to F is a leap; '
      'moving from C to F/C or C/E to F is a step, and the progression starts '
      'to sound arranged rather than strummed.',
  'chord-inversions.fretboard':
      'C major tones across the neck, any of which '
      'can be the lowest',

  'chord-voicings.title': 'Voicings',
  'chord-voicings.summary':
      'The same chord, arranged differently across the strings.',
  'chord-voicings.keywords':
      'voicing, shell, drop 2, open voicing, spread, arrangement',
  'chord-voicings.p1':
      'A voicing is a specific arrangement of a chord\'s notes: which ones are '
      'played, in what order, and on which strings. Two voicings of Cmaj7 can '
      'sound completely different while remaining the same chord.',
  'chord-voicings.p2':
      'Shell voicings keep only the root, third, and seventh, and they sit '
      'well in a band because they leave room for the bass. Drop 2 voicings '
      'move the second-highest note down an octave, which spreads the chord '
      'and makes it easier to fret.',
  'chord-voicings.b1':
      'Close voicings pack notes together; open voicings spread them out.',
  'chord-voicings.b2':
      'The highest note of a voicing is the one listeners follow, so choose it '
      'deliberately.',
  'chord-voicings.b3':
      'Doubling the third of a chord thickens it; doubling the seventh usually '
      'muddies it.',
  'chord-voicings.fretboard': 'Gmaj7 tones, which every voicing selects from',
};
