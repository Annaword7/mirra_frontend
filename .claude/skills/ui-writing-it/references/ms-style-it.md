# Microsoft Italian Style Guide — дистилляция

Источник: официальный Microsoft Italian Localization Style Guide. Всё ниже — только из PDF, сжато.
Терминология: Microsoft Terminology (learn.microsoft.com → Globalization).

## 1. Канцелярит → бытовые слова

| en-US | Избегать | Писать |
|---|---|---|
| reference | fare riferimento a | vedere |
| want | desiderare | volere |
| can | essere in grado di | riuscire |

Предпочтительное слово и допустимый синоним (для разнообразия, чтобы не повторяться):

| en-US | Предпочтительно | Альтернатива |
|---|---|---|
| use | usare | utilizzare |
| try | provare | tentare |
| find | trovare | individuare |

## 2. Союзы: формальные → простые

| Формально | Живой вариант |
|---|---|
| affinché | per |
| allorquando | quando |
| benché | nonostante |
| ogniqualvolta | ogni volta che |

Начинать предложение с союза можно только ради эмфазы: «…queste nuove funzionalità. E non è tutto.»

## 3. Предлоги: типовые ловушки перевода

| en-US | it | Комментарий |
|---|---|---|
| Save on the disk | Salvare su disco | буквальный перевод — ок |
| the Open command on the File menu | il comando Apri **dal** menu File | on → da |
| Click the button | Fare clic **sul** pulsante | после fare clic предлог обязателен |
| data from the database | i dati **del** database | from-принадлежность → di |

## 4. Короткие бытовые формы

Разрешён только устоявшийся минимум:

| en-US | Полная форма | В UI |
|---|---|---|
| PC | personal computer | PC |
| cellular phone | telefono cellulare | cellulare |
| email | messaggio di posta elettronica | e-mail / email |
| email server | server di posta elettronica | server e-mail / server email |
| info | informazioni | info |
| app | applicazione | app |

## 5. Ошибки: стиль и стандартные формулы

Стиль:
- Естественно и эмпатично, не по-роботски: «La password non è corretta. Prova di nuovo ricordando che nelle password devi specificare correttamente maiuscole e minuscole.» · «Il codice Product Key non funziona. Verifica di averlo inserito correttamente e riprova.» · «C'è un problema. Non trovo i file scaricati per creare l'unità flash USB di avvio.»
- Имя продукта не делать подлежащим: Word cannot open this document → «Non è possibile aprire il documento». Если источник надо назвать (ОС, много компонентов): «Data Protection Manager: non è possibile copiare i file nel percorso selezionato».
- Персонализация допустима, когда субъект несёт информацию: «Il driver non riconosce il comando specificato» · «RASMXS.DLL non riesce a caricare RASSER.DLL».
- Можно простое настоящее без potere: «Il dispositivo da cui stai tentando di registrare non riconosce il formato di file corrente.»
- essere по возможности опускать: «Funzione non supportata» · «Parametro non valido passato a una funzione di sistema» · «Numero di errore specificato non definito nel sistema».

| en-US | it | Пример |
|---|---|---|
| Cannot… / Could not… / Failed to… | Non è possibile… (не «Impossibile») | Non è possibile salvare i file |
| Cannot find… / Unable to locate… | Non è possibile trovare… | Non è possibile trovare il documento richiesto |
| Not enough / Insufficient memory | Memoria insufficiente (per…) | Memoria insufficiente per caricare il programma |
| …is not available / unavailable | …non disponibile | Documento non disponibile |

## 6. Плейсхолдеры

%d, %ld, %u, %lu — число · %c — буква · %s — строка.
Подстановка должна согласоваться по роду и числу, поэтому формулируй нейтрально:
- «Accesso non consentito a %s»
- «Non è possibile utilizzare %s»
- «Installazione di %s non riuscita a causa di un errore interno»
- «Non è possibile impostare %1 come organizzatore perché non ha un indirizzo e-mail» (не «perché lei/lui non ha…»)

## 7. Гендер-нейтральность и инклюзивная лексика

Стратегии, в порядке предпочтения:
1. Видимость женского рода: gli sviluppatori e le sviluppatrici; профессии в ж. р.: deputata, avvocata, sindaca, ministra, ingegnera.
2. Скрыть род: persona, essere umano; собирательные: personale, corpo docente, direzione; chi + глагол: chi insegna, chi studia, chi utilizza; перефраз: Benvenuto → Ti diamo il benvenuto, Sei sempre aggiornato → Hai sempre gli ultimi aggiornamenti; пассив: L'iscrizione può essere fatta online; безличность: Chi si iscrive al webinar può…
3. Расширенный мужской plural — когда пункты 1–2 дают громоздкость или неоднозначность (норма для UI).

Запрещено: артикль перед фамилией женщины (la Meloni ✗); signorina; суффиксы через слэш (ragazzo/a ✗ — слэш только в бланках: Firma del/della richiedente); символы * и ə (benvenut*, tuttə ✗).

Родовые роли нейтрализовать не нужно: il fornitore, l'operatore, il gestore, il rivenditore; в UI также l'amministratore, l'organizzatore.

| Писать | Не писать |
|---|---|
| subordinato | schiavo |
| rete perimetrale | zona demilitarizzata |
| corpo elettorale | votanti |
| persona esperta | guru |
| personale · organico · forza lavoro · team | signore e signori · gente |
| docente | maestra o maestro |
| persona della strada | uomo della strada |
| a misura umana | a misura d'uomo |
| genere umano · umanità · essere umano | uomo |
| popolazioni primitive | uomo primitivo |
| fatto a mano | fatto dall'uomo |
| diritti umani | diritti dell'uomo |

Инвалидность: persona con disabilità / persona disabile — не handicappato, portatore di handicap, diversamente abile, invalido, i disabili; persona senza disabilità — не normodotato, abile. Инвалидность не упоминать без необходимости; без жалости (colpito da, affetto da ✗).

Доступность:
- Универсальные глаголы ввода: Selezionare (не Fare clic / Toccare), Inserire (не Digitare).
- Описывай событие, а не способность: Appare un messaggio (не Si vede un messaggio); Il sistema emette un avviso (не Si sente un avviso).
- e, più, circa — словами, не символами &, +, ~ (скринридеры их путают).

## 8. Пунктуация

Общее: перед знаком препинания пробела нет, после — ровно один.

**Запятая**
- Никогда между подлежащим и сказуемым: Il file è stato rimosso (не «Il file, è stato rimosso»).
- Не ставить перед e / o / oppure, если это не вводный оборот: Assegna autorizzazioni a utenti o gruppi.
- Не ставить после ориентирующих вводных: Nella finestra di dialogo Trova fare clic su Opzioni.

**Двоеточие**
- После двоеточия на той же строке — строчная: NOTA: per aprire un file, fare clic su Apri. Исключение — заголовки: Passaggio 1: Creazione di un modello.
- Если продолжение с новой строки — заглавная.
- Внутри предложений не злоупотреблять; лучше «, ad esempio …»: I database sono costituiti da diversi oggetti, ad esempio tabelle, query, report e così via.

**Тире и дефис**
- Em dash (—) не используется вообще. Пара понятий в заголовке — дефис: Database - Concetti essenziali · Modelli di Word - Cartella.
- Вставки — запятыми, часто с ovvero: L'account corrente, ovvero quello utilizzato dall'utente corrente per l'accesso, appartiene…
- En dash: минус (-20°) и диапазоны чисел (0-1).
- Дефис: переносы и сложные слова (pre-elaborazione).

**Многоточие**
- В прогресс-сообщениях и командах UI сохраняется: Salva con nome… · Rimozione dei file dal computer in corso…
- В документации при упоминании такой команды — убирается: scegliere Salva con nome dal menu File.

**Точка** — конец предложения и сокращения (см. §9): Impostaz. e-mail.

**Кавычки** — только точные цитаты и названия документов: vedere "Creazione di un modello". Не для эмфазы (эмфаза — курсив). Одинарных избегать; в софте допустимо повторять кавычки исходника. Знаки препинания — снаружи кавычек.

**Скобки**
- Только когда без них никак; вставки — запятыми: Il file corrente, di proprietà dell'amministratore, non può essere spostato.
- Отдельное предложение в скобках после точки — нельзя.
- Знаки препинания — снаружи скобок.

**Символы**: без пробела между знаком и словом: Microsoft® è un marchio…

## 9. Сокращения и числа

- По возможности не сокращать вообще.
- Правила усечения: убрать минимум 2 буквы; обрезать на согласной и поставить точку; при двойной согласной — обрезать на второй: Abbreviaz. · Visualizz. · Geogr.
- Употребимые: art., ca., cfr., ecc., n., NB, p., pp., all., app., cap., par., sez.; единицы без точки: cm, mm, m, km, g, kg, s, min, h, KB, MB, GB, Kb, Mb, MHz, GHz.
- Множественное число заимствований = единственному, число показывают артикль и глагол: I file sono stati eliminati.

## 10. Акронимы и артикли

- Род акронима = род опорного слова перевода: l'API (interfaccia — ж. р.); la password (напоминает parola); il Web, lo swapping (w считается согласной); l'host (артикль как перед «o»); il widget.
- Для ясности можно ставить опорное слово: l'interfaccia API.
- Локализованный акроним — расшифровка в скобках при первом упоминании: UE (Unione Europea).
- Нелокализуемый: API (Application Programming Interface); если расшифровка переводима — обе через запятую: ANSI (American National Standards Institute, Istituto americano per gli standard nazionali).
- Непереведённые названия продуктов и фич — без артикля: installare .NET Framework · con Microsoft Word.
- Переведённые фичи: физический объект — с артиклем (la Calcolatrice, il Blocco note); абстракция — без (Esplora file, Accesso remoto); мастера всегда с артиклем: l'Installazione guidata, la Creazione guidata modello.

## 11. Клавиши и шорткаты

Названия клавиш — капсом: INVIO, ESC, CANC, MAIUSC, CTRL, ALT, TAB, FINE, HOME, INSERT, BACKSPACE, PAUSA, STAMP, BLOC MAIUSC, BLOC NUM, BLOC SCORR, BARRA SPAZIATRICE, PGSU, PGGIÙ, FRECCIA SU / GIÙ / DESTRA / SINISTRA, TASTO WINDOWS.
В беглом тексте: freccia SU (слово freccia строчными, направление капсом).

Итальянские шорткаты часто не совпадают с en. Отличающиеся из гайда:

| Команда | en | it |
|---|---|---|
| Apri | Ctrl+O | CTRL+F12 |
| Trova | Ctrl+F | CTRL+T |
| Vai a | Ctrl+G | CTRL+B |
| Grassetto | Ctrl+B | CTRL+G |
| Sottolineato | Ctrl+U | CTRL+S |
| Allineato al centro | Ctrl+E | CTRL+A |
| Allineato a sinistra | Ctrl+L | CTRL+T |
| Giustificato | Ctrl+J | CTRL+F |

Остальные из таблицы гайда совпадают с en (CTRL+C, CTRL+V, CTRL+Z, CTRL+S Salva, CTRL+H Sostituisci, F1 Guida, F12 Salva con nome и т. д.).
Access keys: значимые буквы, обычно первая буква команды; консистентность с Office и Windows. Клавиши цифрового блока отдельно не оговаривать без необходимости.

## 12. Copilot-промты

- Промты функциональны: точно, консистентно, кратко, естественно — от их качества зависит ответ ИИ.
- Начинай с глагола действия, конкретика без размытости: List ideas for a fun remote team building event → «Crea un elenco di idee per un divertente evento di team building a distanza».
- Разговорный, но вежливо-профессиональный тон; без сленга и жаргона, без «машинного» звучания.
- Кавычки исходника сохраняй — они говорят Copilot, что писать или менять.
- Entity-токены не переводятся, но позиция должна ложиться в итальянский синтаксис: «Proponi una nuova introduzione per <entity type='file'>file</entity>» · «Quali sono state le questioni non risolte nella <entity type='meeting'>riunione</entity>?»
- Исключение: если токен — отображаемый текст-пример (DevComment «Translate […]»), его содержимое переводится: «Crea un elenco di <placeholder>nomi di colori ispirati al mare</placeholder>».
- Похожие en-промты переводить единообразно.
