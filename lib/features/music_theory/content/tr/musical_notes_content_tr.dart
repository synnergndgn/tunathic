const musicalNotesContentTr = <String, String>{
  'note-names.title': 'Nota Adları',
  'note-names.summary':
      'Batı müziği yedi harf kullanır: A\'dan G\'ye, sonra baştan başlar.',
  'note-names.keywords': 'alfabe, harfler, doğal, a b c d e f g, perde, nota',
  'note-names.p1':
      'Çaldığınız her sesin bir adı vardır ve temelde yalnızca yedi tane '
      'vardır: A, B, C, D, E, F ve G. G\'den sonra alfabe bir oktav yukarıdan '
      'yeniden A ile başlar. Bu yedi sese doğal nota denir; piyanoda beyaz '
      'tuşlardır.',
  'note-names.example': 'C\'den yazılmış yedi doğal nota',
  'note-names.p2':
      'Aralarındaki boşluklar eşit değildir. Gitarda B ile C ve E ile F bir '
      'perde, diğer bütün komşu harf çiftleri iki perde uzaktır. Majör gama '
      'karakterini veren bu düzensiz desendir ve diyez ile bemollerin var '
      'olma nedeni de budur.',
  'note-names.b1':
      'Standart akortta altı boş telin adı E, A, D, G, B ve E\'dir.',
  'note-names.b2':
      'B ile C ve E ile F arasında nota yoktur, bu yüzden o boşluklarda diyez '
      'ya da bemol bulunmaz.',
  'note-names.b3':
      'Çalarken harfleri yüksek sesle söyleyin; adlandırma teori becerisinden '
      'önce bir hafıza becerisidir.',

  'sharps.title': 'Diyezler',
  'sharps.summary': 'Diyez, notayı bir yarım ses, yani bir perde yukarı taşır.',
  'sharps.keywords': 'diyez, yükseltme, yarım ses, bir perde, arıza işareti',
  'sharps.p1':
      'Diyez işareti notayı bir yarım ses yükseltir. Gitarda bu tam olarak '
      'gövdeye doğru bir perdedir. Fa diyez, Fa\'nın bir perde üstünde; Do '
      'diyez, Do\'nun bir perde üstündedir.',
  'sharps.example': 'Diyez gerektiren ilk ton olan G majör',
  'sharps.p2':
      'Diyezler süs değildir. Bir ton, gamı yedi harfin her birinden bir kez '
      'geçsin diye diyez kullanır. G majör tam olarak bu yüzden F diyeze '
      'ihtiyaç duyar: düz bir F ile gam tepede yanlış duyulurdu.',
  'sharps.b1':
      'Yaygın kullanımda E diyez ve B diyez yoktur, çünkü E ile F ve B ile C '
      'zaten bir yarım ses uzaktır.',
  'sharps.b2':
      'Diyezler tonlar arasında sabit bir sırayla gelir: F, C, G, D, A, E, B.',
  'sharps.b3':
      'Donanımda yazılan bir diyez tek bir nota için değil, tüm parça için '
      'geçerlidir.',

  'flats.title': 'Bemoller',
  'flats.summary': 'Bemol, notayı bir yarım ses, yani bir perde aşağı taşır.',
  'flats.keywords': 'bemol, indirme, yarım ses aşağı, bir perde, arıza işareti',
  'flats.p1':
      'Bemol işareti notayı bir yarım ses indirir; burguluğa doğru bir '
      'perdedir. Si bemol, Si\'nin bir perde altında; Mi bemol, Mi\'nin bir '
      'perde altındadır.',
  'flats.example': 'Bemol gerektiren ilk ton olan F majör',
  'flats.p2':
      'Bemollü tonlar en az diyezli tonlar kadar yaygındır; özellikle nefesli '
      'çalgılar için yazılan müzikte ve cazda. Gitaristler F majör, B bemol '
      'majör ve oralarda duran sayısız şarkı üzerinden bunlarla sürekli '
      'karşılaşır.',
  'flats.b1':
      'Yaygın kullanımda C bemol ve F bemol yoktur; nedeni E diyez ile B '
      'diyezin kullanılmamasıyla aynıdır.',
  'flats.b2':
      'Bemoller tonlar arasında sabit bir sırayla gelir: B, E, A, D, G, C, F.',
  'flats.b3': 'Bir donanım ya diyezlidir ya bemollü. İkisi asla karışmaz.',

  'enharmonics.title': 'Eşsesliler',
  'enharmonics.summary': 'Tek ses, iki ad. F diyez ile G bemol aynı perdedir.',
  'enharmonics.keywords': 'eşsesli, aynı ses, iki ad, yazılış, f diyez g bemol',
  'enharmonics.p1':
      'Aynı perde iki ad taşıyabilir. Gitarda F diyez ile G bemol birebir aynı '
      'duyulur; C diyez ile D bemol de öyle. Sesi paylaşan ama adı farklı olan '
      'notalara eşsesli denir.',
  'enharmonics.exampleSharp': 'Diyezlerle yazılan F diyez majör',
  'enharmonics.exampleFlat': 'Bemollerle yazılan D bemol majör',
  'enharmonics.p2':
      'Hangi adın doğru olduğuna ton karar verir. Bir gam her harfi bir kez '
      'kullanmalıdır, dolayısıyla yazılışı ton belirler. Aynı sesin bir '
      'şarkıda A diyez, başka bir şarkıda B bemol olmasının nedeni budur.',
  'enharmonics.b1':
      'Eşsesli çiftler eşit tamperamanda aynı duyulur; gitar perdeleri de '
      'böyle yerleştirilmiştir.',
  'enharmonics.b2':
      'Kâğıt üzerinde yazılış önemlidir: G bemol majör ile F diyez majör aynı '
      'sestir ama farklı donanımdır.',
  'enharmonics.b3':
      'Emin değilseniz tonu izleyin. Gam Kütüphanesi seçtiğiniz köke göre '
      'notaları sizin için yazar.',

  'octaves.title': 'Oktavlar',
  'octaves.summary':
      'On iki yarım ses yukarıdaki aynı nota: daha tiz ama aynı.',
  'octaves.keywords': 'oktav, on iki perde, katlama, aynı nota, 8va',
  'octaves.p1':
      'Boş E telini çalın, sonra aynı teli on ikinci perdeden çalın. Aynı '
      'notadır, daha tizdir. Bu mesafe bir oktavdır: on iki yarım ses ve '
      'frekansın iki katı.',
  'octaves.p2':
      'Oktavlar tekrar ettiği için klavyenin tamamı bir pozisyon listesi '
      'değil, tekrarlayan bir haritadır. Bir notanın nerede olduğunu öğrenin, '
      'üstüne oktav şeklini ekleyin; onu bulacağınız iki yer daha bilirsiniz.',
  'octaves.b1': 'Aynı telde on iki perde yukarısı her zaman bir oktavdır.',
  'octaves.b2':
      'Alt dört telde iki tel yana ve iki perde yukarı gitmek bir oktavdır.',
  'octaves.b3':
      'Bir gitar ile bir basın aynı partiyi çalıp yine de farklı duyulmasının '
      'nedeni oktavlardır.',

  'scientific-pitch-notation.title': 'Bilimsel Perde Yazımı',
  'scientific-pitch-notation.summary':
      'A4 gibi, harf artı oktav numarasıyla tek bir sesi adlandırma.',
  'scientific-pitch-notation.keywords':
      'spn, a4, e2, orta do, c4, oktav numarası, 440, bilimsel perde',
  'scientific-pitch-notation.p1':
      'Tek başına harf, hangi E\'yi kastettiğinizi söylemez. Bilimsel perde '
      'yazımı bir oktav numarası ekler: E2 kalın boş tel, E4 ince olandır. '
      'Numara A\'da değil, C\'de değişir.',
  'scientific-pitch-notation.example': 'Perde olarak yazılmış standart akort',
  'scientific-pitch-notation.p2':
      'A4, 440 Hz\'deki akort referansıdır ve C4 orta Do\'dur. Gitar Akort '
      'Cihazı hedeflerini böyle adlandırır; altıncı tel için yalnızca E değil '
      'E2 göstermesinin nedeni budur.',
  'scientific-pitch-notation.b1':
      'Oktav numarası nota B\'yi geçince artar, yani B3 doğrudan C4\'ün '
      'altındadır.',
  'scientific-pitch-notation.b2':
      'Gitar yazıldığından bir oktav pes duyulur; yazılı orta Do, C3 '
      'yüksekliğinde çalınır.',
  'scientific-pitch-notation.b3':
      'Akort cihazları, uygulamalar ve ses yazılımları bu yazımı kullanır; '
      'akıcı okumaya değer.',
};
