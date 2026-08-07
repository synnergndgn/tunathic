const rhythmContentEn = <String, String>{
  'bpm.title': 'BPM and Tempo',
  'bpm.summary': 'Beats per minute: how fast the pulse of a piece moves.',
  'bpm.keywords': 'bpm, tempo, speed, metronome, click, pulse',
  'bpm.p1':
      'Tempo is measured in beats per minute. At 60 BPM one beat lasts one '
      'second; at 120 BPM it lasts half a second. The beat is the pulse you '
      'would tap along to, not the fastest note being played.',
  'bpm.slowLabel': 'Slow',
  'bpm.slowValue': '60–80 BPM, ballads and slow blues',
  'bpm.mediumLabel': 'Moderate',
  'bpm.mediumValue': '90–120 BPM, most pop and rock',
  'bpm.fastLabel': 'Fast',
  'bpm.fastValue': '140–180 BPM, punk, bluegrass, and drum and bass halves',
  'bpm.p2':
      'Tempo and feel are different things. The same 90 BPM can sound relaxed '
      'or urgent depending on whether the parts move in quarter notes or '
      'sixteenths, which is why the number alone never describes a groove.',
  'bpm.b1':
      'Practising slowly and raising the tempo in small steps builds accuracy '
      'faster than practising fast.',
  'bpm.b2':
      'Tap along to a recording to find its tempo, then set the Metronome to '
      'match.',
  'bpm.b3':
      'Halving or doubling a tempo often reveals what the drummer is actually '
      'counting.',

  'note-values.title': 'Note Values',
  'note-values.summary': 'How long each note lasts, measured against the beat.',
  'note-values.keywords':
      'note value, whole, half, quarter, eighth, sixteenth, duration, rhythm',
  'note-values.p1':
      'Note values divide time by halves. A whole note lasts four beats in '
      'common time, a half note two, a quarter note one, and an eighth note '
      'half a beat. Each step down splits the previous value in two.',
  'note-values.p2':
      'The bar chart shows those lengths drawn to scale. Counting out loud '
      'while you play is the fastest way to internalise them: one, two, three, '
      'four for quarters, and one-and-two-and for eighths.',
  'note-values.b1':
      'In 4/4 the quarter note gets the beat, so four of them fill a bar.',
  'note-values.b2':
      'Sixteenth notes are counted one-e-and-a, which keeps four subdivisions '
      'audible.',
  'note-values.b3':
      'A note value is relative: at half the tempo, every value lasts twice '
      'as long in seconds.',

  'rests.title': 'Rests',
  'rests.summary': 'Measured silence, written and counted like notes.',
  'rests.keywords': 'rest, silence, pause, count, space, muting',
  'rests.p1':
      'A rest is silence with a length. Every note value has a matching rest, '
      'and rests are counted exactly as carefully as notes: a bar of 4/4 '
      'always adds up to four beats, whether they are played or not.',
  'rests.p2':
      'On guitar a rest is an action, not an absence. Strings ring on unless '
      'you stop them, so a written rest means muting with the fretting hand '
      'or the palm at the right moment.',
  'rests.b1': 'Silence between phrases is what makes the phrases audible.',
  'rests.b2':
      'Funk and reggae rhythm playing is built as much from rests as from '
      'strums.',
  'rests.b3':
      'Practise counting rests out loud so they stay in time rather than '
      'becoming pauses.',

  'dotted-notes.title': 'Dotted Notes',
  'dotted-notes.summary': 'A dot adds half of the note\'s value again.',
  'dotted-notes.keywords': 'dot, dotted, half again, 1.5, dotted quarter',
  'dotted-notes.p1':
      'A dot after a note makes it one and a half times as long. A dotted half '
      'note lasts three beats instead of two, and a dotted quarter lasts one '
      'and a half beats.',
  'dotted-notes.p2':
      'Dotted rhythms create the lopsided feel behind a great deal of pop '
      'writing. A dotted quarter followed by an eighth pushes the second note '
      'off the beat, which is what makes the pattern feel like it leans '
      'forward.',
  'dotted-notes.b1': 'A dot always adds half the value of the note it follows.',
  'dotted-notes.b2':
      'Dotted eighth delays are a standard guitar effect setting for exactly '
      'this reason.',
  'dotted-notes.b3':
      'Two dots add half, then a quarter, though double dots are rare in '
      'popular music.',

  'triplets.title': 'Triplets',
  'triplets.summary': 'Three notes played in the space of two.',
  'triplets.keywords': 'triplet, three, tuplet, 12/8, shuffle, subdivision',
  'triplets.p1':
      'A triplet divides a beat into three instead of two. Three eighth-note '
      'triplets fill one beat, so each one is a third of a beat rather than a '
      'half.',
  'triplets.p2':
      'Triplets change the feel of a piece more than almost anything else. '
      'The same chord progression played in straight eighths and then in '
      'triplets becomes rock and then blues, without a single note changing.',
  'triplets.b1': 'Count triplets as one-trip-let, two-trip-let.',
  'triplets.b2':
      'A whole song built on triplets is often written in 12/8 instead.',
  'triplets.b3':
      'Quarter-note triplets stretch three notes over two beats and are much '
      'harder to feel; count eighths first.',

  'swing.title': 'Swing',
  'swing.summary': 'Uneven eighth notes: long, short, long, short.',
  'swing.keywords': 'swing, shuffle, groove, long short, jazz, triplet feel',
  'swing.p1':
      'Swing plays pairs of eighth notes unevenly. Instead of two equal '
      'halves, the first note takes roughly two-thirds of the beat and the '
      'second takes the last third, which is the first and third notes of a '
      'triplet.',
  'swing.p2':
      'How far the eighths lean is a stylistic choice rather than a fixed '
      'ratio. Hard shuffles sit near the full triplet; modern jazz at fast '
      'tempos flattens almost to straight. Written music simply says swing and '
      'trusts the player.',
  'swing.b1':
      'Blues, jazz, and shuffle rock are swung; most rock and pop is straight.',
  'swing.b2':
      'Tap the triplet underneath while playing the swung eighths to lock the '
      'feel in.',
  'swing.b3':
      'A shuffle rhythm is swing applied to the strumming hand rather than to '
      'a melody.',

  'time-signatures.title': 'Time Signatures',
  'time-signatures.summary':
      'How many beats a bar holds, and which note gets the beat.',
  'time-signatures.keywords':
      'time signature, meter, bar, 4/4, 3/4, 6/8, 5/4, odd time',
  'time-signatures.p1':
      'A time signature has two numbers. The top says how many beats are in a '
      'bar; the bottom says which note value counts as one beat. In 4/4 there '
      'are four beats and the quarter note gets one.',
  'time-signatures.commonLabel': '4/4',
  'time-signatures.commonValue':
      'Four quarter-note beats. The default for rock, pop, and blues.',
  'time-signatures.waltzLabel': '3/4',
  'time-signatures.waltzValue':
      'Three quarter-note beats. Waltzes and many folk songs.',
  'time-signatures.compoundLabel': '6/8',
  'time-signatures.compoundValue':
      'Six eighth notes felt as two groups of three. Ballads and Celtic '
      'music.',
  'time-signatures.oddLabel': '5/4 and 7/8',
  'time-signatures.oddValue':
      'Odd meters, usually felt as uneven groups such as 3 plus 2.',
  'time-signatures.p2':
      'Compound meters like 6/8 are counted in groups rather than in single '
      'beats. Six eighths felt as two groups of three is why 6/8 sounds '
      'rolling while 3/4 sounds like a waltz, even though both hold six '
      'eighth notes.',
  'time-signatures.b1':
      'The bottom number is a note value: 4 means quarter note, 8 means '
      'eighth note.',
  'time-signatures.b2':
      'Set the Metronome accent to the top number to hear the bar line.',
  'time-signatures.b3':
      'Odd meters become easy once you count them in groups instead of '
      'numbers.',
};
