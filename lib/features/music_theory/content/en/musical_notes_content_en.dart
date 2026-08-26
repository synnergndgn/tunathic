const musicalNotesContentEn = <String, String>{
  'note-names.title': 'Note Names',
  'note-names.summary':
      'Western music uses seven letters, A to G, and then starts again.',
  'note-names.keywords': 'alphabet, letters, natural, a b c d e f g, pitch',
  'note-names.p1':
      'Every pitch you play has a name, and there are only seven basic ones: '
      'A, B, C, D, E, F, and G. After G the alphabet restarts at A, one octave '
      'higher. These seven are called natural notes, and on a piano they are '
      'the white keys.',
  'note-names.example': 'The seven natural notes, written from C',
  'note-names.p2':
      'The gaps between them are not equal. B to C and E to F are one fret '
      'apart on the guitar; every other pair of neighbouring letters is two '
      'frets apart. That uneven pattern is what gives the major scale its '
      'character, and it is the reason sharps and flats exist.',
  'note-names.b1':
      'Six open strings in standard tuning are named E, A, D, G, B, and E.',
  'note-names.b2':
      'B to C and E to F have no note between them, so no sharp or flat sits '
      'in those gaps.',
  'note-names.b3':
      'Say the letters out loud while you play them; naming is a memory skill '
      'before it is a theory skill.',

  'sharps.title': 'Sharps',
  'sharps.summary':
      'A sharp raises a note by one semitone, which is one fret higher.',
  'sharps.keywords': 'sharp, raised, semitone up, one fret, accidental',
  'sharps.p1':
      'A sharp sign raises a note by one semitone. On the guitar that is '
      'exactly one fret towards the body. F sharp sits one fret above F, and '
      'C sharp sits one fret above C.',
  'sharps.example': 'G major, the first key that needs a sharp',
  'sharps.p2':
      'Sharps are not decoration. A key uses them so that its scale still '
      'runs through all seven letters once each. G major needs F sharp for '
      'exactly that reason: with a plain F the scale would sound wrong at the '
      'top.',
  'sharps.b1':
      'There is no E sharp or B sharp in normal use, because E to F and B to '
      'C are already one semitone apart.',
  'sharps.b2':
      'Sharps appear in a fixed order across keys: F, C, G, D, A, E, B.',
  'sharps.b3':
      'A sharp written in the key signature applies for the whole piece, not '
      'just for one note.',

  'flats.title': 'Flats',
  'flats.summary':
      'A flat lowers a note by one semitone, which is one fret lower.',
  'flats.keywords': 'flat, lowered, semitone down, one fret, accidental',
  'flats.p1':
      'A flat sign lowers a note by one semitone, one fret towards the '
      'headstock. B flat is one fret below B, and E flat is one fret below E.',
  'flats.example': 'F major, the first key that needs a flat',
  'flats.p2':
      'Flat keys are as common as sharp keys, especially in music written for '
      'horns and in jazz. Guitarists meet them constantly through F major, B '
      'flat major, and the many songs that sit there.',
  'flats.b1':
      'There is no C flat or F flat in normal use, for the same reason E '
      'sharp and B sharp are avoided.',
  'flats.b2': 'Flats appear in a fixed order across keys: B, E, A, D, G, C, F.',
  'flats.b3':
      'A key signature is either sharps or flats. The two are never mixed.',

  'enharmonics.title': 'Enharmonics',
  'enharmonics.summary':
      'One pitch, two names. F sharp and G flat are the same fret.',
  'enharmonics.keywords':
      'enharmonic, same pitch, two names, spelling, f sharp g flat',
  'enharmonics.p1':
      'The same fret can carry two names. F sharp and G flat sound identical '
      'on a guitar, and so do C sharp and D flat. Notes that share a pitch but '
      'not a name are called enharmonic.',
  'enharmonics.exampleSharp': 'F sharp major, spelled with sharps',
  'enharmonics.exampleFlat': 'D flat major, spelled with flats',
  'enharmonics.p2':
      'Which name is correct depends on the key. A scale should use each '
      'letter once, so the key decides the spelling. That is why the same '
      'sound is A sharp in one song and B flat in another.',
  'enharmonics.b1':
      'Enharmonic pairs sound the same in equal temperament, which is how '
      'guitars are fretted.',
  'enharmonics.b2':
      'Spelling matters on paper: G flat major and F sharp major are the same '
      'sound but different key signatures.',
  'enharmonics.b3':
      'When you are unsure, follow the key. The Scale Library spells notes for '
      'you from the root you choose.',

  'octaves.title': 'Octaves',
  'octaves.summary':
      'The same note, twelve semitones higher, sounding higher but identical.',
  'octaves.keywords': 'octave, twelve frets, doubling, same note, 8va',
  'octaves.p1':
      'Play an open E string, then the same string at the twelfth fret. It is '
      'the same note, higher. That distance is an octave: twelve semitones, '
      'and a doubling of frequency.',
  'octaves.p2':
      'Because octaves repeat, the whole fretboard is a repeating map rather '
      'than a list of positions. Learn where one note lives, add an octave '
      'shape, and you know two more places to find it.',
  'octaves.b1': 'Twelve frets up on the same string is always an octave.',
  'octaves.b2':
      'Two strings over and two frets up is an octave on the lower four '
      'strings.',
  'octaves.b3':
      'Octaves are why a guitar and a bass can play the same part and still '
      'sound like different instruments.',

  'scientific-pitch-notation.title': 'Scientific Pitch Notation',
  'scientific-pitch-notation.summary':
      'A letter plus an octave number, like A4, that names one exact pitch.',
  'scientific-pitch-notation.keywords':
      'spn, a4, e2, middle c, c4, octave number, 440',
  'scientific-pitch-notation.p1':
      'A letter alone does not say which E you mean. Scientific pitch notation '
      'adds an octave number, so E2 is the low open string and E4 is the high '
      'one. The number changes at C, not at A.',
  'scientific-pitch-notation.example': 'Standard tuning, written as pitches',
  'scientific-pitch-notation.p2':
      'A4 is the tuning reference at 440 Hz, and C4 is middle C. The Guitar '
      'Tuner names its targets this way, which is why it shows E2 rather than '
      'just E for the sixth string.',
  'scientific-pitch-notation.b1':
      'The octave number increases when the note passes B, so B3 is directly '
      'below C4.',
  'scientific-pitch-notation.b2':
      'Guitar sounds one octave lower than written, so written middle C is '
      'played at C3 pitch.',
  'scientific-pitch-notation.b3':
      'Tuners, apps, and audio software all use this notation, so it is worth '
      'reading fluently.',
};
