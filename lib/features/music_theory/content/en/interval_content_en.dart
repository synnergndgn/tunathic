const intervalContentEn = <String, String>{
  'interval-basics.title': 'How Intervals Work',
  'interval-basics.summary':
      'An interval is the distance between two notes, counted in semitones.',
  'interval-basics.keywords':
      'interval, distance, semitone, half step, whole step, number, quality',
  'interval-basics.p1':
      'An interval is the distance between two pitches. On a guitar the '
      'smallest step is one fret, called a semitone or half step. Two frets '
      'make a whole step.',
  'interval-basics.p2':
      'Every interval has a number and a quality. The number counts letters '
      'from the lower note to the higher one, including both. The quality '
      'says whether that distance is major, minor, perfect, augmented, or '
      'diminished. C to E spans three letters, so it is a third, and it is '
      'four semitones wide, so it is major.',
  'interval-basics.example': 'C major, the reference for interval numbers',
  'interval-basics.b1':
      'Fourths, fifths, unisons, and octaves are perfect. Seconds, thirds, '
      'sixths, and sevenths are major or minor.',
  'interval-basics.b2':
      'Lowering a major interval by one semitone makes it minor; lowering a '
      'perfect interval makes it diminished.',
  'interval-basics.b3':
      'Intervals are what chords and scales are made of, so learning them '
      'once pays for itself in every other category.',

  'interval-perfect-unison.summary':
      'Zero semitones: the same note, played twice or doubled.',
  'interval-perfect-unison.keywords':
      'unison, same note, doubling, p1, zero semitones',
  'interval-perfect-unison.character':
      'A unison has no tension at all. Two instruments in unison sound like '
      'one louder, thicker instrument, which is why doubled guitar parts feel '
      'solid rather than busy.',
  'interval-perfect-unison.usage':
      'Unisons are used to reinforce a melody, and slightly detuned unisons '
      'create chorus and twelve-string shimmer. On the guitar they also appear '
      'as the same pitch on two adjacent strings.',
  'interval-perfect-unison.b1':
      'The open B string and the fourth fret of the G string are a unison.',
  'interval-perfect-unison.b2':
      'Checking those two positions against each other is a classic way to '
      'tune by ear.',
  'interval-perfect-unison.b3':
      'A unison bend plays one note against the same note held on a higher '
      'string.',

  'interval-minor-second.summary':
      'One semitone: the tightest, most dissonant step in the system.',
  'interval-minor-second.keywords':
      'minor second, half step, semitone, m2, b2, dissonance, tension',
  'interval-minor-second.character':
      'A minor second grinds. Two notes one fret apart clash hard, which '
      'makes it the sound of suspense, horror scores, and flamenco tension.',
  'interval-minor-second.usage':
      'It is the leading-tone pull from the seventh degree to the tonic, and '
      'the defining colour of the Phrygian mode. Used as a passing note it '
      'adds bite without taking over.',
  'interval-minor-second.b1':
      'Any two adjacent frets on one string are a minor second.',
  'interval-minor-second.b2':
      'The open B string against the first fret of the B string is the '
      'clearest example.',
  'interval-minor-second.b3':
      'In E Phrygian the move from E to F is a minor second, and it is the '
      'whole flavour of that sound.',

  'interval-major-second.summary':
      'Two semitones: the ordinary step that scales are built from.',
  'interval-major-second.keywords':
      'major second, whole step, tone, m2, two semitones, sus2',
  'interval-major-second.character':
      'A major second is mildly tense but easy on the ear. It sounds like '
      'movement rather than conflict, which is why melodies mostly travel in '
      'these steps.',
  'interval-major-second.usage':
      'It builds sus2 chords, gives add9 chords their open colour, and forms '
      'five of the seven steps in a major scale.',
  'interval-major-second.b1':
      'Two frets apart on one string is a major second.',
  'interval-major-second.b2':
      'C to D, D to E, and F to G are all major seconds.',
  'interval-major-second.b3':
      'Dsus2 rings because the E sits a major second above the D root.',

  'interval-minor-third.summary':
      'Three semitones: the interval that makes a chord minor.',
  'interval-minor-third.keywords':
      'minor third, m3, b3, minor chord, sad, three semitones',
  'interval-minor-third.character':
      'A minor third is warm and slightly sad. It is the single interval most '
      'listeners hear as "minor", and it colours everything built on it.',
  'interval-minor-third.usage':
      'It sits at the bottom of every minor triad and minor seventh chord, '
      'and it is the first step of the minor pentatonic scale that most rock '
      'and blues soloing lives in.',
  'interval-minor-third.b1': 'Three frets up on one string is a minor third.',
  'interval-minor-third.b2':
      'A to C, played as the fifth string open and the fifth string third '
      'fret, is a minor third.',
  'interval-minor-third.b3':
      'Stack a minor third then a major third and you have a minor triad.',

  'interval-major-third.summary':
      'Four semitones: the interval that makes a chord major.',
  'interval-major-third.keywords':
      'major third, m3 major, 3, major chord, bright, four semitones',
  'interval-major-third.character':
      'A major third is bright and settled. It is the sound of a major chord '
      'and, for most listeners, the sound of resolution and daylight.',
  'interval-major-third.usage':
      'It defines major and dominant chords, and it is the interval two '
      'guitars use for classic harmony lines in country and southern rock.',
  'interval-major-third.b1': 'Four frets up on one string is a major third.',
  'interval-major-third.b2':
      'The open G string and the open B string are a major third apart, which '
      'is why standard tuning breaks its pattern there.',
  'interval-major-third.b3':
      'C to E is the major third that turns a bare C and G into a full C '
      'major chord.',

  'interval-perfect-fourth.summary':
      'Five semitones: open, stable, and built into the guitar\'s tuning.',
  'interval-perfect-fourth.keywords':
      'perfect fourth, p4, 4, sus4, five semitones, quartal',
  'interval-perfect-fourth.character':
      'A perfect fourth sounds open and unresolved rather than tense. It '
      'suggests something is about to move without saying where.',
  'interval-perfect-fourth.usage':
      'It creates sus4 chords, drives quartal voicings in modern jazz, and is '
      'the interval between most adjacent guitar strings.',
  'interval-perfect-fourth.b1':
      'Five frets up on one string is a perfect fourth, which is exactly how '
      'standard tuning is built.',
  'interval-perfect-fourth.b2':
      'The open A string and the open D string are a perfect fourth apart.',
  'interval-perfect-fourth.b3':
      'Dsus4 holds a G against the D root, and resolving it to F sharp is one '
      'of the most used moves in rock.',

  'interval-tritone.summary':
      'Six semitones: exactly half an octave, restless and unstable.',
  'interval-tritone.keywords':
      'tritone, augmented fourth, diminished fifth, b5, #4, six semitones, '
      'devil in music',
  'interval-tritone.character':
      'A tritone splits the octave in half and refuses to settle. Medieval '
      'writers nicknamed it the devil in music; today it is the engine of '
      'blues, jazz, and metal alike.',
  'interval-tritone.usage':
      'It lives inside every dominant seventh chord, between the third and '
      'the seventh, and that instability is what makes a V7 chord want to '
      'resolve. It is also the blue note of the blues scale.',
  'interval-tritone.b1':
      'Six frets up on one string is a tritone, and so is six frets down.',
  'interval-tritone.b2':
      'In G7 the B and the F are a tritone apart, and both notes move by a '
      'semitone when the chord resolves to C.',
  'interval-tritone.b3':
      'The same distance is written as an augmented fourth or a diminished '
      'fifth depending on the key.',

  'interval-perfect-fifth.summary':
      'Seven semitones: the strongest, most consonant interval after the '
      'octave.',
  'interval-perfect-fifth.keywords':
      'perfect fifth, p5, 5, power chord, seven semitones, circle of fifths',
  'interval-perfect-fifth.character':
      'A perfect fifth is solid and hollow at once. It carries no major or '
      'minor colour, which is exactly why distorted guitars use it.',
  'interval-perfect-fifth.usage':
      'It is the power chord, the top of every basic triad, and the step that '
      'orders the entire circle of fifths and every key relationship in it.',
  'interval-perfect-fifth.b1':
      'Two frets up and one string over is a perfect fifth on the lower '
      'strings.',
  'interval-perfect-fifth.b2':
      'The open A string and the open E string are a perfect fifth apart.',
  'interval-perfect-fifth.b3':
      'A5 played on the fifth and fourth strings is nothing but a root and a '
      'perfect fifth.',

  'interval-minor-sixth.summary':
      'Eight semitones: dark, wide, and full of longing.',
  'interval-minor-sixth.keywords':
      'minor sixth, m6, b6, eight semitones, dark, inversion of major third',
  'interval-minor-sixth.character':
      'A minor sixth is expressive and slightly melancholy. It is wide enough '
      'to feel like a leap and dark enough to feel serious.',
  'interval-minor-sixth.usage':
      'It appears as the sixth degree of the natural minor scale and gives '
      'minor keys their weight. Turn it upside down and it becomes a major '
      'third.',
  'interval-minor-sixth.b1': 'Eight frets up on one string is a minor sixth.',
  'interval-minor-sixth.b2': 'In A natural minor, A up to F is a minor sixth.',
  'interval-minor-sixth.b3':
      'Lowering the sixth of a major scale is the quickest way to hear a '
      'bright key turn shadowy.',

  'interval-major-sixth.summary':
      'Nine semitones: open, sweet, and instantly recognisable.',
  'interval-major-sixth.keywords':
      'major sixth, m6 major, 6, nine semitones, sixth chord, country',
  'interval-major-sixth.character':
      'A major sixth is warm and lyrical, wide but never tense. It is the '
      'sound of an old standard rather than a modern dissonance.',
  'interval-major-sixth.usage':
      'It defines C6 and other sixth chords, drives country double stops, and '
      'is the interval most people hear at the start of a familiar sweeping '
      'melody.',
  'interval-major-sixth.b1': 'Nine frets up on one string is a major sixth.',
  'interval-major-sixth.b2':
      'Sixth double stops on the third and first strings are the backbone of '
      'country and soul rhythm playing.',
  'interval-major-sixth.b3':
      'Turn a major sixth upside down and you get a minor third.',

  'interval-minor-seventh.summary':
      'Ten semitones: the bluesy tension inside every dominant chord.',
  'interval-minor-seventh.keywords':
      'minor seventh, m7, b7, ten semitones, dominant, blues, mixolydian',
  'interval-minor-seventh.character':
      'A minor seventh is restless but friendly. It adds motion without the '
      'harshness of a semitone clash, which is why it appears in almost every '
      'blues, funk, and soul chord.',
  'interval-minor-seventh.usage':
      'Adding it to a major triad makes a dominant seventh; adding it to a '
      'minor triad makes a minor seventh. It is also the flat seventh that '
      'defines the Mixolydian mode.',
  'interval-minor-seventh.b1':
      'Ten frets up on one string is a minor seventh, but the usable shape is '
      'three frets down and two strings over.',
  'interval-minor-seventh.b2':
      'In G7 the F sitting above the G root is a minor seventh.',
  'interval-minor-seventh.b3':
      'The open E and the open D strings are a minor seventh apart.',

  'interval-major-seventh.summary':
      'Eleven semitones: lush, modern, and one semitone from home.',
  'interval-major-seventh.keywords':
      'major seventh, maj7, 7, eleven semitones, jazz, lush',
  'interval-major-seventh.character':
      'A major seventh sits one semitone below the octave, so it shimmers '
      'rather than resolves. It sounds sophisticated, calm, and slightly '
      'unfinished.',
  'interval-major-seventh.usage':
      'It creates maj7 chords, the standard sound of jazz, bossa nova, and '
      'modern pop ballads, and it is the leading tone that pulls upward in a '
      'major scale.',
  'interval-major-seventh.b1':
      'Eleven frets up on one string is a major seventh, one fret short of '
      'the octave.',
  'interval-major-seventh.b2':
      'In Cmaj7 the B against the C root is a major seventh.',
  'interval-major-seventh.b3':
      'Play the octave, then drop the top note one fret, and you hear the '
      'interval appear.',

  'interval-octave.summary':
      'Twelve semitones: the same note again, higher and unmistakable.',
  'interval-octave.keywords':
      'octave, p8, twelve semitones, twelve frets, doubling, 8va',
  'interval-octave.character':
      'An octave is total agreement. The two notes blend so completely that '
      'most listeners hear one pitch rather than two.',
  'interval-octave.usage':
      'Octaves thicken riffs without adding harmony, which is why jazz and '
      'funk players use them for single-note lines. They also anchor how you '
      'navigate the fretboard.',
  'interval-octave.b1':
      'Twelve frets up on the same string is always an octave.',
  'interval-octave.b2':
      'Two strings over and two frets up is an octave on the sixth and fifth '
      'strings.',
  'interval-octave.b3':
      'Two strings over and three frets up is the same shape once it crosses '
      'the G string.',
};
