# Microsoft Turkish Style Guide — дистилляция

Источник: Microsoft Turkish Localization Style Guide. Всё ниже — сжатые таблицы и правила из него; ничего сверх PDF.

## 1. Канцелярит → разговорное (words and phrases to avoid)

Старотурецкие/формальные слова дают ненужную серьёзность. Заменять бытовыми:

| en-US | Избегать | Использовать |
|---|---|---|
| through | suretiyle | aracılığıyla, yoluyla |
| surely | muhakkak | kesinlikle |
| to make sure | maksadıyla | amacıyla |
| so that | dolayısıyla | böylece, bu sayede |
| quickly | hızlı bir şekilde, ivedilikle | hızla |
| via | vasıtasıyla | aracılığıyla, yoluyla |
| possibly | muhtemel | olası |
| possibility | ihtimal | olasılık |
| problem, issue, failure | arıza, başarısızlık | sorun, hata |
| in the end, last | nihayet | son, sonunda |
| currently | halihazırda | şu anda |
| in, within | içerisinde | içinde |

Бытовой словарь:
- **PC** → «bilgisayar» (слово «PC» — только когда в тексте противопоставлены Mac и PC).
- **manually** → «kendiniz» (стандартное «el ile» звучит неуместно при обращении к пользователю).
- **item** → называть предмет конкретно: «dosya», «klasör», «resim»; «öğe» — не бытовое слово, только когда конкретизировать нельзя.

## 2. Формальные связки → разговорные
- Не повторять один союз дважды: «...sola veya sağa kaydırın **ya da** farklı bir arama terimi deneyin» (не «veya ... veya»).
- Длинное предложение с союзом лучше разбить на два.
- Сцепка деепричастием вместо «ve»: «alıcıyı **silip** tekrar deneyin» вместо «silin ve tekrar deneyin».
- Не начинать предложение с союза ради «разговорности» — в турецком это не работает так, как в английском.

## 3. please / sorry
- «**Lütfen**» — когда просим сделать неудобное, подождать или софт причинил неудобство: «İsteğiniz işlenemedi. Lütfen daha sonra yeniden deneyin.»
- «**Özür dileriz**» — только серьёзные проблемы (потеря данных, работа невозможна, нужен специалист): «Bu sorun nedeniyle özür dileriz.»
- Прочие случаи — «**maalesef**» / «**ne yazık ki**»: «Maalesef hizmet şu anda kullanılamıyor.»
- «**Üzgünüz**» — калька, не использовать никогда. Английский «sorry» чаще, чем нужен в турецком — не копировать.

## 4. Гендер-нейтральность и инклюзивная лексика

| Использовать | Не использовать |
|---|---|
| insanlık | insanoğlu |
| bilim insanı | bilim adamı, bilim kadını |
| iş insanı | iş adamı, iş kadını |
| kişi; birey; insan | adam |
| kadın | bayan |
| erkek | adam |
| olgun (insan); doğru şekilde; gerektiği gibi | baba (adam); adam gibi; adamakıllı |
| eş; partner; sevgili | kız arkadaş; erkek arkadaş; karı; koca |
| ebeveyn | anne veya baba |
| uzman | usta (в знач. guru) |
| engelleme | kara listeye alma |
| iş arkadaşları; ekip; herkes | kadınlar, erkekler; hanımlar, beyler |
| geçmişte yeterince temsil edilmemiş | azınlık |
| siyahi | zenci |
| yarı yarıya ödemek | Alman usülü ödemek |

Местоимения:
- she/he → нейтральное «o» и его суффиксные формы; часто работает прямой перевод.
- Перестройка: 2-е/3-е лицо (siz, o), множественное число («Kullanıcılar bu cümleyi silebilir»), определённое существительное вместо местоимения («söz konusu belge» вместо «onun belgesi»), роль («okuyucu», «çalışan», «müşteri»), «kişi/kişiler».
- Избегать гендерных заимствований (müdür/müdire → нейтральная роль).
- Обобщения — множественным числом: «kişiler», «öğrenciler».

Инвалидность — «люди, а не диагнозы», без жалости:

| Использовать | Не использовать |
|---|---|
| özel gereksinimli birey; engelli (birey); tekerlekli sandalye kullanan | özürlü; tekerlekli sandalyeye mahkum; sakat; topal |
| işitme engelli kişi; işitme güçlüğü çeken kişi | sağır; sağır ve dilsiz |
| görme engelli kişi; görme güçlüğü çekenler | kör |
| zihinsel engelli kişi; zihinsel rahatsızlık yaşayanlar | akıl hastası; deli; çatlak; kaçık; spastik |

Доступность в инструкциях:
- Обобщённые глаголы для всех способов ввода: «**Seçin**», не «Tıklayın».
- Одно действие-глагол на предложение; текст должен нормально звучать в скринридере.
- «ve, ile, ayrıca, yaklaşık» — писать словами, не символами (&, +, ~): скринридеры их путают.

## 5. Стандартные фразы ошибок

Пассив — стандарт для этих конструкций; меняется только основной глагол:

| en-US | Шаблон | Пример |
|---|---|---|
| Cannot… / Could not… | … yapılamıyor | İleti gönderilemiyor. |
| Failed to… / Failure of… | … yapılamadı | İleti gönderilemedi. |
| Cannot find… / Unable to locate… | … bulunamıyor | İleti bulunamıyor. |
| Not enough / insufficient memory | Bellek yetersiz / Bellek yeterli değil | — |
| … is not available / unavailable | … yok / … kullanılamıyor | Erişim izni yok. Ağ paylaşımı kullanılamıyor. |

Стиль ошибок:
- Естественно и эмпатично, не «робот»: «Maalesef bu alan boş olamaz…», «Bu komutu işlemek için bellek yeterli değil.»
- Логический порядок событий важнее порядка слов источника: «E-posta sunucusuyla iletişim kurulamadığından, sunucu e-posta bildirimi gönderemiyor.»
- Терминология и стиль ошибок консистентны по всему продукту.
- «Something bad happened!» → коротко и просто: «Bir sorun var! …»

## 6. Плейсхолдеры (в т.ч. с числами)

Значения: `%d, %ld, %u, %lu` = число; `%c` = буква; `%s` = строка.

| en-US | Турецкий | Правило |
|---|---|---|
| Could not locate %s on server %s | %s, %s sunucusunda bulunamıyor | Ненумерованные плейсхолдеры не переставлять |
| Unable to delete %s | %s silinemiyor | Содержимое неизвестно → никаких суффиксов к плейсхолдеру |
| %d items cannot be deleted | %d öğe silinemiyor | После числа — единственное число |
| Copying: %d%% | Kopyalama sürüyor: %%%d | Знак % в турецком стоит ПЕРЕД числом |

- При локализации выяснять, что подставится, — иначе грамматика сломается.
- Плейсхолдеры и порядок слов часто требуют перестройки всего предложения.

## 7. Пунктуация

**Em dash (—)**: в турецком не применяется. Заменять двоеточием, точкой с запятой, скобками или перестройкой. Пример: «Arrange your files—quickly» → «Dosyalarınızı hızla düzene sokun» (не «…düzene sokun—hızla»).

**En dash (–)**: минус — без пробела после знака («-5»); диапазоны — без пробелов вокруг («Sayfa 3-5»).

**Дефис**: употребление очень ограничено; английские дефисные композиты — раздельно или слитно: «user-specified parameter» → «kullanıcı tarafından belirtilen parametre».

**Многоточие**: ровно три точки, без пробела перед ними; в софте — для идущих процессов в настоящем продолженном: «Güncelleştirmeler indiriliyor...».

**Двоеточие**: после него заглавная, если дальше полное предложение; строчная, если фрагмент: «Bu uygulama şu özelliklere sahip değildir: kesme-yapıştırma, sürükleyip bırakma.» В заголовках документов двоеточие не ставить.

**Точка с запятой**: после неё — строчная; не ставить после подлежащего длинного предложения (там достаточно запятой).

**Запятая**: ставить по необходимости (пропуск меняет смысл), но не перегружать — лучше разбить предложение. Нужна, когда подлежащее и сказуемое далеко друг от друга.

**Восклицательный знак**: в турецком реже, чем в английском; из источника не копировать без нужды.

**Кавычки**: прямые "…".

**Скобки**: без пробелов внутри; если в скобках полное предложение — точка внутри скобок; фрагмент — сразу после дополняемой части, не в начале и не «хвостом» в конце; суффиксы вешать на слово ПЕРЕД скобками: «Gerekli Windows sürümünü (Windows 10 ve sonrası) yükleyin.»

**Точка**: после точки один пробел (двойные пробелы источника не копировать).

## 8. Сокращения, аббревиатуры, числа

Сокращения слов — последний выход при нехватке места (кнопки, опции). Два способа: выбрасывание гласных («program» → «pgm», «mesaj» → «msj») или усечение конца с точкой.
- Названия продуктов не сокращать никогда.
- В заголовках сокращений не быть.
- Лучше сокращения — перенос/дефисация или короткий синоним.

Акронимы:
- Большинство — как в английском; локализованных мало: USA → ABD, OVR → ÜYZ.
- Нелокализованные склоняются: читается как слово → склонять как слово; нет гласных/не читается → по буквам, суффикс по последней букве: «OLE DB'den», «SMTP'ye», «API'si».
- Известные (MSN, IP) можно читать по-английски и склонять соответственно.

Числа: правила написания — TDK: https://www.tdk.gov.tr/icerik/yazim-kurallari/sayilarin-yazilisi/
Единицы: «25 min. @ 25 Gbps» → «25 Gb/sn hızda 25 dk.»

## 9. Символы и неразрывные пробелы
- @, #, & в турецком тексте не используются: «# items» → «Öğe sayısı»; «Bullets & Numbering» → «Madde İşaretleri ve Numaralandırma».
- «&» → «ve» в связном тексте; оставлять «&» только в тегах, плейсхолдерах, шорткатах и коде.
- Неразрывный пробел: между названием продукта и версией — нужен; между обычными словами — нет; лишние из источника удалять.

## 10. Клавиши и шорткаты

Локализуемые имена клавиш (остальные — как в английском: Esc, Enter, Home, End, Delete, Caps Lock, Num Lock, Page Up/Down, Pause, Break, Print Screen, Scroll Lock, Shift, Alt, Insert, Tab→см. ниже):

| English | Турецкий |
|---|---|
| Backspace | Geri Al |
| Ctrl | Control (в тексте); в сочетаниях остаётся Ctrl |
| Down / Up / Left / Right Arrow | Aşağı Ok / Yukarı Ok / Sol Ok / Sağ Ok |
| Spacebar | Ara çubuğu |
| Tab | Sekme |
| Windows key | Windows tuşu |
| Menu key | Menü tuşu |

Сочетания: Alt+Tab → **Alt+Sekme**, Ctrl+Tab → **Ctrl+Sekme**, Ctrl+Backspace → **Ctrl+Geri Al**, Alt+Spacebar → **Alt+Ara çubuğu**; F1, Esc, Alt+F4 и т.п. — без изменений.

Турецкие шорткаты форматирования отличаются от английских:
İtalik **Ctrl+T**, Kalın **Ctrl+K**, Altı çizili **Ctrl+A**, Tümü büyük harf **Ctrl+Shift+F**, Küçük büyük harf **Ctrl+Shift+I**; Ortalanmış **Ctrl+R**, Sola hizalanmış **Ctrl+L**, Sağa hizalanmış **Ctrl+G**, Yaslanmış **Ctrl+D**.

Access keys: «тонкие» буквы (I, l, t, r, f) — можно; буквы с нижними выносами (g, j, y, p, q), расширенные символы, буква/цифра/знак в скобках после названия — можно, но не предпочтительно; дубли допустимы, если букв не осталось; для второстепенных опций можно не назначать. Имена клавиш — обычным текстом, не капителью.

## 11. Copilot-промты (предзаданные подсказки для AI)
- Промт — естественный вопрос или просьба, начинается с глагола действия; формулировки конкретные, без расплывчатости.
- Разговорный тон по принципам Microsoft voice, неформальное обращение; без «машинного» звучания, без сленга и жаргона; вежливо.
- Кавычки — чтобы показать ИИ, что именно писать/менять/заменять.
- Entity-токены (`<entity type='file'>` и т.п.) не локализуются; их позиция должна быть синтаксически осмысленной. Исключение: если DevComment велит переводить (промт — display text), токен переводится.
- Похожие английские промты переводить консистентно.

Примеры:
- «List ideas for a fun team building event» → «Ekip ruhunu canlandıracak eğlenceli bir etkinlik için öneri listesi oluştur»
- «Propose a new introduction to <entity type='file'>file</entity>» → «<entity type='file'>Dosya</entity> için yeni bir giriş bölümü öner»
- «Create a travel itinerary <placeholder>exploring Istanbul</placeholder>.» → «<placeholder>İstanbul'u keşfetmeye</placeholder> yönelik bir seyahat programı oluştur.»

## 12. Прочие приёмы естественности
- Притяжательность из английского не тащить: «Set Up Your Device» → «Cihazı Ayarla».
- Идиомы: перевести смысл или опустить, если смысл не теряется: «We've hit a snag…» → «Bir engelle karşılaştık…»; «Crashes happen.» → «Bilgisayarınız kilitlenebilir.»
- Не злоупотреблять одним послелогом («için» дважды в предложении → заменить один на «üzere» и т.п.).
- Местоимения: не выбрасывать бездумно (частая ошибка), но и не плодить — лучше поменять порядок слов; нулевое подлежащее — только когда субъект однозначен.
- Композиты: свежая орфография TDK — многие пишутся раздельно: «olağan dışı» (не «olağandışı»), «bal kabağı» (не «balkabağı»).
- Названия продуктов и торговые марки не переводить; «Version 8.1» → «Sürüm 8.1»; копирайтные строки переводить по Microsoft Terminology.
