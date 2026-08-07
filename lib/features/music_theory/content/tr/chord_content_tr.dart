const chordContentTr = <String, String>{
  'triads.title': 'Üçlü Akorlar',
  'triads.summary':
      'Üç nota: bir kök, üstüne bir üçlü ve bir beşli, akoru oluşturur.',
  'triads.keywords': 'üçlü akor, majör, minör, kök üçlü beşli, 1 3 5, akor',
  'triads.p1':
      'Üçlü akor en küçük tam akordur: bir kök, bir üçlü ve bir beşli. Üçlü '
      'akorun majör mü minör mü duyulacağına karar verir; beşli ise akoru '
      'sağlam tutar.',
  'triads.exampleMajor': 'Kökü, büyük üçlüsü ve tam beşlisiyle C majör',
  'triads.exampleMinor': 'Üçlüsü indirilmiş aynı yapı: A minör',
  'triads.p2':
      'Eksik ve artık üçlü akorlar beşliyi de değiştirir. Eksik akor beşliyi '
      'indirir ve dengesiz duyulur; artık akor onu yükseltir ve yukarı doğru '
      'gerilmiş gibi duyulur. İkisi de majör ve minör kadar yaygın değildir '
      'ama ikisi de sıradan tonların içinde bulunur.',
  'triads.b1':
      'Majör 1, 3, 5\'tir. Minör 1, pes 3, 5\'tir. Yalnızca tek nota değişir.',
  'triads.b2':
      'Çoğu açık gitar akoru yeni nota eklemek yerine aynı üç notayı altı tele '
      'yayar.',
  'triads.b3':
      'Bu kategorideki her akor, bir şey eklenmiş ya da değiştirilmiş bir üçlü '
      'akordur.',
  'triads.fretboard': 'İlk beş perdede C majör',

  'seventh-chords.title': 'Yedili Akorlar',
  'seventh-chords.summary':
      'Kökün bir yedili üstüne eklenen dördüncü nota: renk ya da çekim.',
  'seventh-chords.keywords':
      'yedili, maj7, m7, dominant yedili, 7, dört notalı akor',
  'seventh-chords.p1':
      'Bir üçlü akorun üstüne bir üçlü daha koyun; yedili akoru elde '
      'edersiniz. Hangi yediliyi eklediğiniz her şeyi değiştirir: büyük yedili '
      'zengin ve sakin, küçük yedili bluesvari, dominant yedili ise bir yere '
      'gitmesi gerekiyormuş gibi duyulur.',
  'seventh-chords.example': 'C majörün dominant yedilisi olan G7',
  'seventh-chords.p2':
      'Bu üçü içinde en güçlüsü dominant yedilidir, çünkü içinde bir triton '
      'barındırır. O triton dengesizdir ve onu çözmek, V7\'den I\'e '
      'ilerlemesini bir bitiş gibi duyuran şeydir.',
  'seventh-chords.b1':
      'maj7 1 3 5 7, dominant 7 1 3 5 pes 7 ve m7 1 pes 3 5 pes 7\'dir.',
  'seventh-chords.b2':
      'm7b5 diye yazılan yarı eksik akor, majör bir tonun yeden sesi üzerine '
      'kurulan yedili akordur.',
  'seventh-chords.b3':
      'Gitarda yedili akorun beşlisini atabilirsiniz; akor yine tam duyulur.',

  'suspended-chords.title': 'Askılı Akorlar',
  'suspended-chords.summary':
      'Üçlüyü ikili ya da dörtlüyle değiştirin; akor majör ya da minör olmaktan '
      'çıkar.',
  'suspended-chords.keywords': 'sus, sus2, sus4, askılı, üçlüsüz, açık',
  'suspended-chords.p1':
      'Askılı akor, akoru majör ya da minör yapan üçlüyü kaldırır ve yerine '
      'bir ikili veya dörtlü koyar. Sonuç mutlu ya da hüzünlü değil, açık ve '
      'çözülmemiş duyulur.',
  'suspended-chords.example': 'F diyez yerine G bulunan Dsus4',
  'suspended-chords.p2':
      'Askılar genellikle bir varış noktası değil bir andır. Dsus4 çalıp '
      'ardından D çalmak gitarın en tanınan hareketlerinden biridir, çünkü '
      'kulak üçlünün gelmesini bekler.',
  'suspended-chords.b1': 'sus2 1, 2, 5\'tir. sus4 1, 4, 5\'tir.',
  'suspended-chords.b2':
      'Sus akoru ne majör ne minördür, bu yüzden ikisinin de üstüne oturur.',
  'suspended-chords.b3':
      'Açık D ve A şekillerinde tek parmağı kaldırmak ya da eklemek askıyı '
      'anında verir.',

  'augmented-chords.title': 'Artık Akorlar',
  'augmented-chords.summary':
      'Beşlisi yükseltilmiş majör akor: huzursuz ve simetrik.',
  'augmented-chords.keywords': 'artık, aug, artı, yükseltilmiş beşli, tam ses',
  'augmented-chords.p1':
      'Artık üçlü akor, beşlisi bir yarım ses yükseltilmiş bir majör akordur. '
      'İçinde üst üste iki büyük üçlü barındırır; bu da onu kusursuz simetrik '
      've havada asılı, yerleşmemiş bir ses yapar.',
  'augmented-chords.example': 'G yerine G diyez bulunan C artık akoru',
  'augmented-chords.p2':
      'Şekil her dört yarım seste bir tekrar ettiği için tek bir artık akor '
      'üç akor işi görür. En çok geçit akoru olarak kullanılır; yükseltilmiş '
      'beşli bir sonraki akor sesine tırmanır.',
  'augmented-chords.b1': 'Artık akor 1, 3, yükseltilmiş 5\'tir.',
  'augmented-chords.b2': 'Caug, Eaug ve G diyez aug aynı üç notayı içerir.',
  'augmented-chords.b3':
      'I ile vi arasında deneyin: C, Caug, Am akıcı bir yükselen hat verir.',

  'diminished-chords.title': 'Eksik Akorlar',
  'diminished-chords.summary':
      'Üst üste küçük üçlüler: çözülmek isteyen gergin akorlar.',
  'diminished-chords.keywords': 'eksik, dim, dim7, yarı eksik, m7b5, pes beşli',
  'diminished-chords.p1':
      'Eksik üçlü akor hem üçlüyü hem beşliyi indirir. Üstüne bir eksik yedili '
      'ekleyin; her nota bir sonrakinden üç yarım ses uzakta durur ve yine '
      'kusursuz simetrik bir akor çıkar.',
  'diminished-chords.example': 'C majörün yedinci derecesindeki akor: Bm7b5',
  'diminished-chords.p2':
      'm7b5 diye yazılan yarı eksik akor günlük olanıdır: her minör tonun ii '
      'akorudur. Tam eksik yedililer dramatik geçişler için kullanılır, çünkü '
      'dört notasının herhangi biri kök gibi davranabilir.',
  'diminished-chords.b1':
      'Eksik üçlü akor 1, pes 3, pes 5\'tir. Eksik yedili buna çift pes 7 '
      'ekler.',
  'diminished-chords.b2': 'Eksik yedili şekli her üç perdede bir tekrar eder.',
  'diminished-chords.b3':
      'm7b5, V7 ve i sıralaması minör bir ton ilerlemesinin standart '
      'açılışıdır.',

  'extended-chords.title': 'Genişletilmiş Akorlar',
  'extended-chords.summary':
      'Yedili akorun üstüne yığılan dokuzlular, on birliler ve on üçlüler.',
  'extended-chords.keywords':
      'genişletilmiş, 9, 11, 13, add9, gerilim sesleri, caz',
  'extended-chords.p1':
      'Bir yedili akorun üstüne üçlü yığmayı sürdürün; dokuzluya, on birliye '
      've on üçlüye ulaşırsınız. Bu notalar ikinci, dördüncü ve altıncı ile '
      'aynıdır; yalnızca yedilinin üstünde durdukları için bir oktav yukarıda '
      'yazılırlar.',
  'extended-chords.example': 'Dokuzlusu eklenmiş büyük yedili akor: Cmaj9',
  'extended-chords.p2':
      'Altı tel altı notayı rahatça taşıyamaz, bu yüzden gitaristler nota '
      'eler. İlk gidenler kök ve beşlidir, çünkü akorun kimliğini üçlü ile '
      'yedili, rengini ise genişletme taşır.',
  'extended-chords.b1':
      'add9 yedili olmadan dokuzluyu ekler; 9 akoru yediliyi de içerir.',
  'extended-chords.b2':
      'Dominant akorda on birli genellikle yükseltilir, çünkü doğal on birli '
      'büyük üçlüyle çarpışır.',
  'extended-chords.b3':
      '13 akoru pratikte genellikle kök, üçlü, yedili ve on üçlüdür.',

  'chord-inversions.title': 'Çevrimler',
  'chord-inversions.summary': 'Basta farklı bir nota bulunan aynı akor.',
  'chord-inversions.keywords':
      'çevrim, slash akor, bas notası, birinci çevrim, ikinci çevrim, c/e',
  'chord-inversions.p1':
      'Çevrim akorun bütün notalarını korur ama en pesteki notayı değiştirir. '
      'Basta E bulunan C majör birinci çevrimdir ve C/E yazılır; basta G '
      'bulunan ise ikinci çevrimdir ve C/G yazılır.',
  'chord-inversions.example': 'Üç notasının her biri basa gelebilen C majör',
  'chord-inversions.b1':
      'Kök konumda kök, birinci çevrimde üçlü, ikinci çevrimde beşli en '
      'pestedir.',
  'chord-inversions.b2':
      'Yedili akorun basta yedilinin durduğu bir üçüncü çevrimi de vardır.',
  'chord-inversions.b3':
      'Slash yazımı önce akoru, sonra eğik çizginin ardından bas notasını '
      'adlandırır.',
  'chord-inversions.p2':
      'Çevrimler bas hattını yumuşatmak için vardır. C\'den F\'ye gitmek bir '
      'sıçramadır; C\'den F/C\'ye ya da C/E\'den F\'ye gitmek bir adımdır ve '
      'ilerleme çalınmış değil düzenlenmiş duyulmaya başlar.',
  'chord-inversions.fretboard':
      'Klavye boyunca C majör sesleri; her biri en peste düşebilir',

  'chord-voicings.title': 'Seslendirmeler',
  'chord-voicings.summary': 'Aynı akorun tellere farklı biçimde yerleşmesi.',
  'chord-voicings.keywords':
      'seslendirme, dizilim, shell, drop 2, açık dizilim, düzenleme',
  'chord-voicings.p1':
      'Seslendirme, bir akorun notalarının belirli bir yerleşimidir: hangileri '
      'çalınır, hangi sırayla ve hangi tellerde. Cmaj7\'nin iki seslendirmesi '
      'aynı akor olmayı sürdürürken tamamen farklı duyulabilir.',
  'chord-voicings.p2':
      'Shell seslendirmeleri yalnızca kökü, üçlüyü ve yediliyi tutar ve '
      'toplulukta iyi oturur, çünkü basa yer bırakır. Drop 2 seslendirmeleri '
      'üstten ikinci notayı bir oktav indirir; bu akoru yayar ve basmayı '
      'kolaylaştırır.',
  'chord-voicings.b1':
      'Kapalı seslendirmeler notaları sıkıştırır, açık olanlar yayar.',
  'chord-voicings.b2':
      'Dinleyici seslendirmenin en tiz notasını izler, bu yüzden onu bilerek '
      'seçin.',
  'chord-voicings.b3':
      'Akorun üçlüsünü katlamak akoru kalınlaştırır; yediliyi katlamak '
      'genellikle bulandırır.',
  'chord-voicings.fretboard': 'Her seslendirmenin seçtiği Gmaj7 sesleri',
};
