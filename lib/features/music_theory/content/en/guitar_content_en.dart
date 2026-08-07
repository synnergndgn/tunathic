const guitarContentEn = <String, String>{
  'standard-tuning.title': 'Standard Tuning',
  'standard-tuning.summary':
      'E A D G B E, and why the pattern breaks on the second string.',
  'standard-tuning.keywords':
      'standard tuning, eadgbe, open strings, fourths, major third',
  'standard-tuning.p1':
      'Standard tuning is E2, A2, D3, G3, B3, E4 from the lowest string up. '
      'Every neighbouring pair is a perfect fourth apart except G to B, which '
      'is a major third.',
  'standard-tuning.example': 'Standard tuning, low to high',
  'standard-tuning.p2':
      'That one irregularity is a compromise. All fourths would make scales '
      'perfectly regular but chords far harder to grip; the major third makes '
      'open chords playable at the cost of one shifted shape in every pattern '
      'that crosses the B string.',
  'standard-tuning.b1': 'The outer strings are both E, two octaves apart.',
  'standard-tuning.b2':
      'Five frets up on any string gives the next string open, except on the '
      'G string, where it is four.',
  'standard-tuning.b3':
      'Every shape you learn shifts one fret when it crosses from the G string '
      'to the B string.',

  'alternate-tunings.title': 'Alternate Tunings',
  'alternate-tunings.summary':
      'Retuning strings to change what the instrument makes easy.',
  'alternate-tunings.keywords':
      'drop d, dadgad, open g, open d, half step down, alternate tuning',
  'alternate-tunings.p1':
      'An alternate tuning changes which chords fall under the fingers. Drop '
      'D lowers only the sixth string, so a power chord becomes one finger. '
      'Open tunings put a full chord under an open strum, which is why slide '
      'players use them.',
  'alternate-tunings.example': 'Tunings the Guitar Tuner already supports',
  'alternate-tunings.p2':
      'Retuning does not change theory; it changes geography. The same '
      'intervals exist, but the shapes that produce them move, so patterns '
      'learned in standard tuning have to be relearned rather than '
      'transposed.',
  'alternate-tunings.b1':
      'Drop D keeps five strings in standard tuning, so most shapes still '
      'work.',
  'alternate-tunings.b2':
      'Open G is D G D G B D, the tuning behind a great deal of slide and '
      'Stones-style rhythm playing.',
  'alternate-tunings.b3':
      'Tuning down a semitone lowers the pitch without changing any shape.',

  'capo.title': 'Using a Capo',
  'capo.summary':
      'A movable nut that raises the key while keeping open shapes.',
  'capo.keywords': 'capo, clamp, key change, open shapes, transpose, singer',
  'capo.p1':
      'A capo clamps across a fret and becomes a new nut. Everything above it '
      'behaves like an open guitar, so open chord shapes keep working while '
      'the actual pitch rises by one semitone per fret.',
  'capo.fret2Label': 'Capo on fret 2',
  'capo.fret2Value': 'A G shape sounds as A, and a C shape sounds as D.',
  'capo.fret3Label': 'Capo on fret 3',
  'capo.fret3Value': 'A G shape sounds as B flat, and an E shape as G.',
  'capo.fret5Label': 'Capo on fret 5',
  'capo.fret5Value': 'A C shape sounds as F, and an A shape as D.',
  'capo.p2':
      'A capo is a tool for singers and for texture, not a shortcut around '
      'theory. Two guitarists playing the same song with capos at different '
      'frets and different shapes is one of the oldest ways to make an '
      'arrangement sound full.',
  'capo.b1':
      'Add the capo fret number to the shape name in semitones to find the '
      'sounding chord.',
  'capo.b2': 'A capo raises pitch only. It cannot lower a key.',
  'capo.b3':
      'Place it just behind the fret, not on top of it, to avoid pulling the '
      'strings sharp.',

  'transposition.title': 'Transposition',
  'transposition.summary':
      'Moving a whole piece to another key without changing its shape.',
  'transposition.keywords':
      'transpose, change key, semitones, singer, roman numerals, capo',
  'transposition.p1':
      'Transposing moves every note and chord by the same interval. The '
      'relationships stay identical, which is why a transposed song is still '
      'recognisably the same song.',
  'transposition.p2':
      'The reliable method is to think in degrees. Write the progression as '
      'Roman numerals, choose the new key, and read the numerals back. '
      'Compare the two tables below: I, IV, and V in C are C, F, and G, and in '
      'G they are G, C, and D.',
  'transposition.b1':
      'Transposing up two semitones turns C into D and F into G.',
  'transposition.b2':
      'A capo transposes upward while keeping the original shapes.',
  'transposition.b3':
      'The Repertoire transposes stored songs for you, spelling the chords to '
      'suit the new key.',

  'chord-construction-on-guitar.title': 'Building Chords on Guitar',
  'chord-construction-on-guitar.summary':
      'Six strings, four notes: what to keep and what to leave out.',
  'chord-construction-on-guitar.keywords':
      'build chords, omit fifth, doubling, voice leading, shapes, guitar '
      'voicing',
  'chord-construction-on-guitar.p1':
      'A guitar has six strings and most chords have three or four notes, so '
      'building a chord means deciding what to double and what to omit. The '
      'root, third, and seventh carry the identity; the fifth rarely does.',
  'chord-construction-on-guitar.fretboard':
      'A7 tones across the first seven frets',
  'chord-construction-on-guitar.p2':
      'This is why professional players often use three-note voicings. '
      'Dropping the fifth and any doubled notes leaves a chord that states '
      'exactly what it is, sits out of the bass player\'s way, and moves to '
      'the next chord with minimal hand movement.',
  'chord-construction-on-guitar.b1':
      'Never omit the third unless you want a suspended or power chord sound.',
  'chord-construction-on-guitar.b2':
      'Omit the fifth first, then the root if a bass is covering it.',
  'chord-construction-on-guitar.b3':
      'Doubling the root or fifth is safe; doubling an extension usually is '
      'not.',

  'scale-positions.title': 'Scale Positions',
  'scale-positions.summary':
      'Covering the neck by dividing a scale into playable regions.',
  'scale-positions.keywords':
      'position, box, three notes per string, shifting, neck coverage, '
      'fingering',
  'scale-positions.p1':
      'A scale spans the whole neck, but a hand covers four or five frets. A '
      'position is one such region, fingered so that the hand stays still and '
      'every scale note within reach is available.',
  'scale-positions.fretboard': 'G major from the second to the ninth fret',
  'scale-positions.p2':
      'Two systems dominate. Three notes per string gives even, fast patterns '
      'that suit legato and picking exercises; CAGED positions tie each region '
      'to a chord shape, which keeps soloing connected to the harmony '
      'underneath.',
  'scale-positions.b1':
      'Learn where positions overlap, so you can shift without a gap in the '
      'line.',
  'scale-positions.b2':
      'Practise one position against a backing chord before adding the next.',
  'scale-positions.b3':
      'Knowing the root notes inside each position matters more than knowing '
      'the shape.',
};
