# Microsoft Style Guide de-DE — дистилляция

Источник: German Localization Style Guide (Microsoft, 2026). Только то, что есть в PDF.

## 1. Канцелярит → разговорные слова

### Английские пары (words to avoid → preferred) — ориентир при переводе с en
achieve→do · attempt→try · configure→set up · execute→run · halt→stop · however→but · in addition→also · locate→find · modify→change · navigate→go · obtain→get · perform→do · purchase→buy · refer to→see · resolve→fix · subsequent→next · terminate→end · utilize→use · as well as→also, too · have an opportunity→can · in conjunction with→with · make a recommendation→recommend · provide guidance→help

### Немецкие пары (избегать → использовать)
| Избегать | Использовать |
|---|---|
| Unterstützung bieten | unterstützen, helfen |
| partiell | teilweise |
| erfordern | benötigen |
| im Internet browsen | im Internet surfen |
| einen Anruf durchführen / telefonieren | einen Anruf tätigen/führen |
| Mobiltelefon | Handy |
| kontaktieren | sich wenden an |
| durchführen (perform) | ausführen |
| nicht ausreichend | nicht genügend |
| fehlgeschlagen | Fehler bei(m) … |
| mit … fortfahren | … fortsetzen (+Akk; без объекта: den Vorgang fortsetzen) |
| dasselbe (в «not the same») | das gleiche |

## 2. Формальные конструкции → разговорные (глагольный стиль)
| Старый стиль | Новый стиль |
|---|---|
| Beim Öffnen des Dokuments werden Ihnen … angezeigt | Wenn Sie das Dokument öffnen, können Sie … sehen |
| Zum Bereitstellen der Anwendung gehen Sie folgendermaßen vor | Um die App bereitzustellen, gehen Sie wie folgt vor |
| Benutzer können den Zeitpunkt … festlegen | Sie bestimmen, wann … |
| Diese Einstellung bietet Benutzern … | Wählen Sie … aus |

Сначала действие, потом цель: `Entfernen Sie alle Einstellungen, um Speicherplatz freizugeben` (не `Um … freizugeben, entfernen Sie …`).

## 3. Короткие бытовые слова (short word forms)
| en | de | Правило |
|---|---|---|
| app | App | вместо Anwendung/Programm |
| info | Info | в casual-контекстах и при нехватке места; Informationen — если ссылка «weitere Informationen finden Sie unter …» |
| PC | PC | Windows-устройства; computer — когда речь о PC и Mac |
| web | Web | casual; Internet — если в источнике Internet |

Допустимые сокращения (стягивания) в правильном контексте: `Versuchen Sie's noch mal.` · `Hätten Sie's gedacht?` · `Jetzt kann's losgehen.` · `So geht's:`

## 4. Ошибки (error messages)
Стиль: естественно, эмпатично, не по-роботски. `Oops, that can't be blank` → `Leider darf dieser Eintrag nicht leer sein …`

### Стандартные фразы
| en | de | Примечание |
|---|---|---|
| Cannot / Could not V | N … kann/konnte nicht (+ Partizip) werden | НЕ начинать с `Kann nicht…` / `Konnte nicht…` |
| Failed to … / Failure of … | Fehler beim + субстантивир. глагол | не «fehlgeschlagen» |
| An error/problem occurred while V-ing | Fehler/Problem beim + Nomen/субст. глагол | не «ist ein Fehler aufgetreten» |
| Cannot find / unable to locate | … kann nicht gefunden werden | finden |
| Not enough / insufficient memory | Nicht genügend Speicher zum + субст. глагол | |
| … is unavailable | … ist nicht verfügbar | |
| The following error occurred: '%s' | Fehler: "%s" (Fehler #…) | сокращать |
| Unknown error. | Unbekannter Fehler. | коротко |
| may + V | V + möglicherweise | не vielleicht/eventuell |
| while V-ing | beim + Nomen | не «während des …» |
| wrong / incorrect | falsch | |
| invalid / illegal / bad (format) | ungültig | beschädigt — если физически повреждено |
| destroyed | beschädigt | |
| re-install / try again | erneut | |
| occur (на экране) | erscheinen | не auftreten |
| Do you want to V? | Möchten Sie … + V? | |
| Are you sure you want to remove? | Möchten Sie "%s" entfernen? | **без wirklich** — звучит пугающе |

### Синтаксис и оформление
- Без персонифицированного субъекта: `Setup cannot find…` → `… wurde nicht gefunden.` Если агент нужен: `von/vom + N`.
- Пассив уместен: объект → подлежащее (`Die ungültige Gleichung kann nicht konvertiert werden.`)
- Полные предложения: артикли и глаголы ставить, даже если в en их нет (`File already exists` → `Die Datei ist bereits vorhanden.`).
- Определённый артикль вместо притяжательного/указательного, если владение не важно: `your system` → `das System`; `this operation` → `des Vorgangs`.
- Точка в конце ошибки, даже если в en её нет. Исключение — однословные (`Druckerfehler`). Восклицательный знак → точка (`Too many files!` → `Zu viele Dateien.`).
- Согласование с плейсхолдером обходить перестройкой: `Replace invalid '%s'?` → `Möchten Sie "%s" (ungültig) ersetzen?`; повторять флектируемые элементы (`ein größeres Bild oder eine größere Auswahl`).
- Повторять глагол для однозначности: `Das Laufwerk %1 ist kein Diskettenlaufwerk oder ist einem Netzlaufwerk zugeordnet.`
- `one or more` → `mindestens ein/eine`. `Anzahl von` (не an/der). `Lesefehler in der Datei` (не auf). `Eingabe hinter dem Dateiende` (не nach).
- Плейсхолдеры: %d/%ld/%u/%lu = число, %c = буква, %s = строка.

## 5. Гендер-нейтральность (прагматичный подход)
Минимизировать generic masculine, не ломая читаемость. Гендерштерн (*) не использовать. Приёмы по убыванию приоритета:
1. **Нейтральное слово:** Team/Gruppe (не Mannschaft), Schulkind, IT Admin, Reiseleitung, Kundschaft, Kollegschaft, Wachpersonal, Lehrkraft, Fachkraft, Feuerwehrleute, Eheleute, Pflegepersonal, Eltern/Elternteil.
2. **Множественное число:** `Nur Organisatoren können Besprechungen stornieren.` · `Benutzer können…`
3. **Субстантивированный партицип (только мн. ч.):** Mitarbeitende, Teilnehmende, Studierende, Lernende. В композитах НЕ использовать: Mitarbeitererfahrung (не Mitarbeitenden-).
4. **«Person»-подход — экономно, последний вариант ед. ч.:** mitarbeitende Person, teilnehmende Person.
5. **Обойти/опустить:** `learn from colleagues` → `voneinander lernen`; `stay safer from hackers` → `Schutz vor Hackingangriffen`; `per-user fee` → `personenbasierte Gebühr`.
6. Не использовать родовые местоимения в generic-ссылках: переформулировать на Sie, мн. ч., артикль (`das Dokument`, не `sein/ihr Dokument`), прямое обращение.

**Оставлять как есть** (устоявшиеся): Benutzer, Kunde, Partner, Organisator. О реальном человеке — его местоимения.

Доступность: `Menschen/Personen mit Behinderung` (не Behinderte), `Menschen ohne Behinderung` (не Normale/Gesunde); `Wählen` (не Klicken — работает для всех способов ввода); primär/untergeordnet (не Master/Slave), Umkreisnetzwerk (не DMZ). Ampersand/+/~ писать словами (und, plus, rund) — скринридеры.

## 6. Пунктуация
- **Em dash (—):** в немецкой документации не используется. Точка/запятая/перестройка.
- **En dash (–):** минус (`– 2.375,99 EUR`, с пробелами) и диапазоны (`S. 10–15`, без пробелов).
- **Дефис:** избегать лишних; сложные композиты разворачивать предлогами/порядком слов.
- **Кавычки:** немецкие „unten/oben“ (ANSI 0132/0147); прямые "…" допустимы технически; одинарные — только по техпричинам.
- **Многоточие:** разговорный регистр, избегать. Исключение — UI-элементы продолжающегося действия, без пробела (`… gibt eine Nachricht ein…`).
- **Двоеточие:** НЕ ставить в конце процедурных заголовков (`So installieren Sie das Programm ABC` — без знака).
- **Точки в списках:** полные предложения — с точкой; продолжения вводной фразы и перечни — без; после одного слова точку не ставить никогда.
- **Запятая:** перед und/oder между двумя полными предложениями — ставить. Инфинитивные группы с zu: запятая обязательна после um/ohne/statt/anstatt/außer/als, при зависимости от существительного, при корреляте (es, dazu, daran).
- **Числа:** DE/AT/LU: `9.999,99 €`, `1.495,68 kg`. CH/LI: `9'999.99 SFR`.
- **Скобки:** без пробелов внутри. Версии: `Android 9.0 oder höher`.

## 7. Сокращения и грамматика
- Допустимые: z. B., d. h., ggf., i. d. R., u. a., u. U., usw., bzw., vgl., u. Ä., z. T., zz. — с неразрывным пробелом (или без пробела, если nbsp невозможен). Точка в конце предложения после сокращения не дублируется.
- НЕ сокращать: oder, und, allgemein, etwas, links, rechts. Сомневаешься — пиши полностью.
- Осторожно: OK — только про интерфейс; MS — нельзя (юридически); US — только в композитах (US-Dollar); 2D/3D без дефиса внутри (3D-Darstellung).
- Единицы: GB, KB, MB, MBit, KBit, MBit/s, B/s, MHz, Pt. (без мн. ч.); знак " для дюймов — только в таблицах/упаковке.
- Акронимы: не дублировать последнее слово (`PIN`, не `PIN-Nummer`; `TCP/IP`, не `TCP/IP-Protokoll`). UA: немецкая полная форма + (англ. полная, аббр.): `Datenzugriffsobjekte (Data Access Objects, DAO)`. Новые немецкие аббревиатуры не изобретать. ANSI, ISO, ISDN, WLAN, HTML, HTTPS — без расшифровки.
- **Генитив:** -es после -s/-ß/-z/-tz/-x (des Verzeichnisses, des Absturzes); где оба варианта — простое -s (des Texts, des Felds, des Vertrags). Аббревиатуры без -s (des PC, des WLAN). К товарным знакам генитив-s НЕ приклеивать (`die Vorteile von Active Desktop`).
- Артикли: продуктовые имена — без артикля; немецкие имена фич — с артиклем (`Öffnen Sie den Task-Manager.`). Род заимствований — по Microsoft Terminology (der Virus, der Blog).
- Заимствованные глаголы спрягаются как слабые: chatten/gechattet, debuggen/debuggt, crawlen/gecrawlt; gelikt/geliked, getimt/getimed — но при флексии только немецкий вариант (der gelikte Beitrag). Мн. ч. заимствований: -s (Proxys, Downloads, Agents), на -er без изменений (Server, Manager), на -or: Editoren, но Locators.
- Слитно/раздельно: sodass, mithilfe, aufgrund, infrage, weitgreifend, schwerwiegend, fertigstellen.

## 8. Композиты и дефисы (реформа 2024)
- До трёх компонентов — слитно (Chatverlauf, Livestreaming, Softwareprogramm), если читаемость не страдает (Back-End — иначе «backend» читается как партицип от backen).
- Длиннее/смешанные de+en — с дефисом: Dropdown-Kombinationsfeld, Homepage-Dateiname, E-Mail-Programm, Drop-down-Menü.
- Английские многословные термины в композите — сквозная дефисация (Durchkopplung): Social-Media-Konto, Data-Science-Einstellungen, Cloud-Computing-Lösung, Pull-Request-Benachrichtigung.
- Имена продуктов не дефисируются внутри; дефис между именем и следующим словом: Visual Studio-Plug-in, Power BI-API, Unreal Engine Blueprints-Verweise. Исключение: `Name Setup` — без дефиса.
- Verb+particle: Add-on, Check-in, Plug-in (частица строчная).
- Англ. noun-noun: Midlife-Crisis, Chat-Widget (или слитно: Firmwareupdate). Англ. adj-noun раздельно: Social Media, Corporate Identity, Pull Request.
- Композиты с Agent — через дефис: Copilot-Agents, Codierungs-Agents.
- Мастера (wizards): 1–2 компонента → `N(-N)-Assistent` (Verbindungs-Assistent, Remoteinstallations-Assistent); 3+ → `Assistent zum <субст. глагол> von N` (Assistent zum Synchronisieren von Dateiordnern) или `Assistent für A+N` (Assistent für geplante Synchronisierung).

## 9. Предлоги (стандарт Microsoft)
migrieren **zu** (не auf/nach) · importieren von/in · exportieren nach · Integration **in** · aktualisieren/upgraden **auf** · hinzufügen **+Dativ** (`dem Konto hinzugefügt`, не `zum Konto`) · ändern **in** (не auf) · kompatibel **mit** (не zu) · klicken **auf** · zeigen **auf** · verbinden **mit** (не zu) · **auf** der Symbolleiste · **im** Menü · **im** Netz/Internet/Web (не auf dem) · **auf** einer Website/Webseite · willkommen **bei** · `Informationen zu … finden Sie unter …` (не «Für Informationen …»)

## 10. Частые ловушки (frequent errors, anglicisms)
- select = **auswählen** (списки), **aktivieren/deaktivieren** (чекбоксы), **markieren** (выделение текста/ячеек). click = klicken auf; point = zeigen auf; enter/type = eingeben.
- Note: **Hinweis** (сообщение пользователю) vs **Notiz** (заметка пользователя); Anmerkung — только рядом с remark.
- holidays = Feiertage (не Urlaub) · Middle East = Naher Osten (не Mittlerer Osten) · billion = Milliarde (не Billion) · `for several minutes` = `mehrere Minuten lang` (не `für mehrere Minuten`).
- Идиомы не переводить дословно: `We've hit a snag.` → `Wir sind leider auf ein Problem gestoßen.` Если идиому можно опустить без потери смысла — опустить.
- «My»-терминология: притяжательное опускать (My Documents → Eigene Dateien).
- Английский Title Case не копировать; немецкая капитализация. Заглавная ẞ допустима в верхнем регистре (STRAẞE).

## 11. Клавиши и шорткаты
- Имена клавиш капсом; первое упоминание: `die ESC-TASTE`, далее просто `Drücken Sie ESC`. В комбинациях и таблицах без TASTE: `ALT+O`, `UMSCHALT+NACH-LINKS-TASTE`. Если имя есть на клавише (ALT) — без -TASTE.
- Соответствия: CTRL→STRG · SHIFT→UMSCHALT · ENTER→EINGABE · BACKSPACE→RÜCK · DEL→ENTF · INS→EINFG · HOME→POS1 · END→ENDE · PAGE UP/DOWN→BILD-AUF/BILD-AB · SPACEBAR→LEER · CAPS LOCK→FESTSTELL · PRINT SCREEN→DRUCK · SCROLL LOCK→ROLLEN · NUM LOCK→NUM · стрелки→NACH-LINKS/-RECHTS/-OBEN/-UNTEN-TASTE · WINDOWS-TASTE, MENÜTASTE.
- Примеры шорткатов: STRG+C Kopieren, STRG+V Einfügen, STRG+Z Rückgängig, STRG+A Alles markieren, STRG+F Suchen, ALT+F4, STRG+UMSCHALT+ESC (Task-Manager). Kursiv=STRG+UMSCHALT+K, Fett=STRG+UMSCHALT+F.
- Access keys: буквы с нижними выносами и узкие (l, t, j, g) — можно; буква/цифра/знак в скобках после пункта меню — для немецкого нельзя; дубли допустимы, если букв не хватает.

## 12. Copilot-промты
- Обращение к ИИ на **du**, императив: `Liste Ideen für ein unterhaltsames Remote-Teambuilding auf.`
- Ясно и конкретно, разговорно, вежливо; без сленга и жаргона; следить за пунктуацией и грамматикой — от этого зависит качество ответов Copilot.
- Кавычки использовать, чтобы Copilot понял, что писать/менять.
- **Entity-токены** (`<entity type='file'>file</entity>`, `[file]`): текст внутри переводить (Datei, Besprechung), атрибут type — нет. Позиция токена должна работать в немецком синтаксисе; глаголы с отделяемой приставкой (vorschlagen) не годятся, если приставка окажется за токеном — брать другой глагол (`Empfiehl eine neue Einführung in <entity type='file'>Datei</entity>`).
- **Ghost-text** (`<placeholder>…</placeholder>`) — в конец предложения: `Erstelle eine Liste von <placeholder>Farbnamen, die vom Ozean inspiriert sind</placeholder>`.
- Похожие промты переводить единообразно.

## 13. Тон: образцы
- `The password isn't correct, so please try again.` → `Das Kennwort ist falsch. Versuchen Sie es noch einmal.`
- `All ready to go` → `Jetzt kann's losgehen.`
- `Would you like to continue?` → `Möchten Sie fortfahren?`
- `It's lonely in here. Go to the Store to add some podcasts.` → `Es ist so leer hier. Besuchen Sie den Store, um Podcasts hinzuzufügen.`
- `Press F1 to get Help` → `Drücken Sie F1, um die Hilfe anzuzeigen.`
- Аудитория <18: du (`Wenn du nicht sicher bist, ob deine Eltern diese Website erlauben, solltest du sie nicht besuchen.`).
