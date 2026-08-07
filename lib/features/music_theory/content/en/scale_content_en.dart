const scaleContentEn = <String, String>{
  'major-scale.title': 'The Major Scale',
  'major-scale.summary':
      'Seven notes in a fixed pattern of whole and half steps.',
  'major-scale.keywords':
      'major, ionian, do re mi, whole half, wwhwwwh, scale, key',
  'major-scale.p1':
      'The major scale is the reference every other scale is described '
      'against. Its pattern is whole, whole, half, whole, whole, whole, half, '
      'and that pattern holds from any starting note.',
  'major-scale.example':
      'C major, the only major scale with no sharps or '
      'flats',
  'major-scale.p2':
      'Because the pattern is fixed, the numbers 1 to 7 mean the same thing in '
      'every key. When a chord is called a flat 3 or a scale is described as '
      'having a sharp 4, the comparison is always to the major scale.',
  'major-scale.b1':
      'The half steps fall between degrees 3 and 4 and between 7 and 1.',
  'major-scale.b2':
      'Every major scale uses each of the seven letters exactly once.',
  'major-scale.b3':
      'The chords built on a major scale give you the whole harmony of the '
      'key.',
  'major-scale.fretboard': 'G major from the second fret',

  'natural-minor-scale.title': 'Natural Minor',
  'natural-minor-scale.summary':
      'The major scale with the third, sixth, and seventh lowered.',
  'natural-minor-scale.keywords':
      'natural minor, aeolian, relative minor, sad scale, minor key',
  'natural-minor-scale.p1':
      'Natural minor is a major scale with three notes lowered: the third, '
      'the sixth, and the seventh. That single change from a bright third to a '
      'lowered one carries most of its darker character.',
  'natural-minor-scale.example':
      'A natural minor, the relative minor of C '
      'major',
  'natural-minor-scale.p2':
      'It contains exactly the same notes as a major scale three semitones '
      'higher. A minor and C major share all seven notes; only the resting '
      'point differs, and that is enough to change the mood completely.',
  'natural-minor-scale.b1':
      'The formula is 1, 2, flat 3, 4, 5, flat 6, flat 7.',
  'natural-minor-scale.b2':
      'The chord on the fifth degree is minor, which is why natural minor can '
      'sound like it never fully resolves.',
  'natural-minor-scale.b3':
      'Rock, folk, and film music all lean heavily on this scale.',

  'harmonic-minor-scale.title': 'Harmonic Minor',
  'harmonic-minor-scale.summary':
      'Natural minor with the seventh raised, creating a strong pull home.',
  'harmonic-minor-scale.keywords':
      'harmonic minor, raised seventh, leading tone, v7 in minor, exotic',
  'harmonic-minor-scale.p1':
      'Harmonic minor raises the seventh degree of natural minor by one '
      'semitone. That gives the scale a leading tone: a note one fret below '
      'the tonic that pulls strongly towards it.',
  'harmonic-minor-scale.example': 'A harmonic minor, with G sharp instead of G',
  'harmonic-minor-scale.p2':
      'The raised seventh also turns the chord on the fifth degree from minor '
      'into a dominant seventh, which is why minor-key songs can end as '
      'firmly as major-key ones. The step from the flat sixth to that raised '
      'seventh is a step and a half, and it is the scale\'s signature sound.',
  'harmonic-minor-scale.b1': 'The formula is 1, 2, flat 3, 4, 5, flat 6, 7.',
  'harmonic-minor-scale.b2':
      'It gives E7 in the key of A minor, the classic turnaround chord.',
  'harmonic-minor-scale.b3':
      'The wide gap between the sixth and seventh degrees is why the scale '
      'sounds Middle Eastern or classical depending on context.',

  'melodic-minor-scale.title': 'Melodic Minor',
  'melodic-minor-scale.summary':
      'Minor at the bottom, major at the top, smoothing the ascent.',
  'melodic-minor-scale.keywords':
      'melodic minor, jazz minor, raised sixth and seventh, ascending',
  'melodic-minor-scale.p1':
      'Melodic minor raises both the sixth and the seventh of natural minor. '
      'That removes the wide leap in harmonic minor and gives a line that '
      'climbs smoothly to the tonic while keeping the minor third.',
  'melodic-minor-scale.example': 'A melodic minor, ascending form',
  'melodic-minor-scale.p2':
      'In classical practice the raised notes are used going up and dropped '
      'going down. Jazz keeps them in both directions and calls the result '
      'jazz minor, which is the parent scale of the altered dominant sound.',
  'melodic-minor-scale.b1': 'The formula is 1, 2, flat 3, 4, 5, 6, 7.',
  'melodic-minor-scale.b2':
      'Only one note separates it from a major scale: the flat third.',
  'melodic-minor-scale.b3':
      'The scale shown here is the ascending form, which is the one used in '
      'jazz.',

  'pentatonic-scales.title': 'Pentatonic Scales',
  'pentatonic-scales.summary': 'Five notes, chosen so that nothing clashes.',
  'pentatonic-scales.keywords':
      'pentatonic, five notes, box, minor pentatonic, major pentatonic, solo',
  'pentatonic-scales.p1':
      'A pentatonic scale drops the two notes most likely to clash. Minor '
      'pentatonic removes the second and the sixth from natural minor; major '
      'pentatonic removes the fourth and the seventh from the major scale.',
  'pentatonic-scales.exampleMinor':
      'A minor pentatonic, the first scale most '
      'guitarists learn',
  'pentatonic-scales.exampleMajor':
      'C major pentatonic, the same five notes '
      'as A minor pentatonic',
  'pentatonic-scales.p2':
      'Minor and major pentatonic are the same set of notes with a different '
      'home. A minor pentatonic and C major pentatonic use identical frets; '
      'which one you hear depends on the chord underneath.',
  'pentatonic-scales.b1': 'Minor pentatonic is 1, flat 3, 4, 5, flat 7.',
  'pentatonic-scales.b2': 'Major pentatonic is 1, 2, 3, 5, 6.',
  'pentatonic-scales.b3':
      'Two notes per string across all six strings makes the familiar box '
      'shape.',
  'pentatonic-scales.fretboard': 'A minor pentatonic in the fifth position',

  'blues-scale.title': 'The Blues Scale',
  'blues-scale.summary':
      'Minor pentatonic plus one extra note that carries the whole style.',
  'blues-scale.keywords':
      'blues, blue note, flat five, six notes, bend, minor pentatonic plus',
  'blues-scale.p1':
      'The blues scale is minor pentatonic with a flat fifth added between '
      'the fourth and the fifth. That single extra note is the blue note, and '
      'it is what makes the scale sound like the blues rather than a plain '
      'minor run.',
  'blues-scale.example': 'A blues, minor pentatonic with the added E flat',
  'blues-scale.p2':
      'The blue note works because it is a passing note, not a destination. '
      'Bend into it, slide through it, or land on it briefly; hold it and the '
      'line stops sounding like blues and starts sounding wrong.',
  'blues-scale.b1': 'The formula is 1, flat 3, 4, flat 5, 5, flat 7.',
  'blues-scale.b2':
      'The flat five is the same tritone that gives dominant chords their '
      'tension.',
  'blues-scale.b3':
      'The scale sits over dominant seventh chords, which is unusual and part '
      'of why blues sounds like it does.',

  'modes.title': 'Modes',
  'modes.summary':
      'Seven scales made by starting the major scale on each of its degrees.',
  'modes.keywords':
      'mode, modal, dorian, phrygian, lydian, mixolydian, locrian, ionian, '
      'aeolian',
  'modes.p1':
      'Play a C major scale but treat D as home, and you get D Dorian. The '
      'notes are unchanged; the centre of gravity moved. Doing this from each '
      'degree gives the seven modes.',
  'modes.exampleDorian': 'D Dorian, minor with a bright natural sixth',
  'modes.exampleMixolydian': 'G Mixolydian, major with a flat seventh',
  'modes.exampleLydian': 'F Lydian, major with a raised fourth',
  'modes.p2':
      'A mode only sounds modal when the harmony supports it. Playing D '
      'Dorian over a C chord just sounds like C major; play it over a Dm chord '
      'and the sixth degree becomes audible as the defining colour.',
  'modes.b1':
      'Dorian, Phrygian, and Aeolian are the minor modes; Ionian, Lydian, and '
      'Mixolydian are the major ones.',
  'modes.b2':
      'Locrian has a flat fifth, which leaves it without a stable home chord.',
  'modes.b3':
      'Learn each mode by the one note that separates it from plain major or '
      'minor.',
};
