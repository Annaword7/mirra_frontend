# Microsoft Localization Style Guide — English (UK): дистилляция

Источник: официальный Microsoft Localization Style Guide, English (UK). Только то, что есть в гайде; ничего не додумано.

## 1. Канцелярит → простые слова (words and phrases to avoid)

| Избегать (en-US/формально) | Использовать (en-GB) |
|---|---|
| achieve | do |
| as well as | also, too |
| attempt | try |
| configure | set up |
| encounter | meet |
| execute | run |
| halt | stop |
| have an opportunity | can |
| however | but |
| give/provide guidance, give/provide information | help |
| in addition | also |
| in conjunction with | with |
| locate | find |
| make a recommendation | recommend |
| modify | change |
| navigate | go |
| obtain | get |
| perform | do |
| purchase | buy |
| refer to | see |
| resolve | fix |
| subsequent | next |
| suitable | works well |
| terminate | end |
| toggle | switch |
| utilize | use |

## 2. Выбор слов (word choice)

| Слово | Правило |
|---|---|
| app | вместо application / program |
| pick / choose | pick — лёгкие, fun-контексты («pick a colour»); choose — формальнее; select — только если требует UI |
| drive | общий термин для любого диска; конкретный тип — если нужно |
| get | ок как «получить», избегать в прочих значениях |
| info | по умолчанию; information — если лучше по контексту; «for more info, see <link>» |
| PC | для персональных устройств; computer — когда речь о PC и Mac |
| you | обращаться к человеку на you; «user» не использовать — формально и безлично |

Короткие слова из повседневной речи — дружелюбнее, экономят место, быстрее читаются.

## 3. Сокращения (contractions)

Использовать везде, где возможно: cannot → can't, do not → don't, it will → it'll, would have → would've, they would → they'd.

## 4. Стандартные фразы ошибок (error messages)

Стиль: естественный, эмпатичный, не робот. Терминология и формулировки — единообразные, не переводить каждую ошибку по-своему.

| Варианты en-US | Стандарт en-GB |
|---|---|
| Cannot… / Could not… | Cannot… |
| Failed to… / Failure of… | Failed to… |
| Cannot find… / Could not find… / Unable to find… / Unable to locate… | Cannot find… |
| Not enough memory / Insufficient memory / There is not enough memory (available) | Not enough memory |
| …is not available / …is unavailable | …is not available |
| Sorry, that can't be blank… | Sorry, that's not right… |

Плейсхолдеры в ошибках: `%d`, `%ld`, `%u`, `%lu` = число; `%c` = буква; `%s` = строка. Узнать, что подставится, и построить грамматичную фразу; плейсхолдер не локализуется.

## 5. Инклюзивная лексика

| Использовать | Не использовать |
|---|---|
| primary/subordinate | master/slave |
| perimeter network | demilitarized zone (DMZ) |
| stop responding | hang |
| expert | guru |
| meeting | pow wow |
| colleagues; everyone; all | guys; ladies and gentlemen |
| lunch and learn; learning session | brown bag session |
| parent | mother or father |

### Гендер-нейтральность

| Использовать | Не использовать |
|---|---|
| chair, moderator | chairman |
| humanity, people, humankind | man, mankind |
| operates, staffs | mans |
| sales representative | salesman |
| synthetic, manufactured | manmade |
| workforce, staff, personnel | manpower |

Не использовать he/him/she/her в обобщениях. Приёмы: второе лицо (you), множественное число («Developers need access… they don't»), артикль вместо местоимения (the document, не his document), роль (reader, customer), person/individual. Если никак — singular they допустим; he/she и s/he — нет. Про реального человека — его местоимения.

### Доступность

| Использовать | Не использовать |
|---|---|
| person with a disability | handicapped; differently abled |
| disabled people; people with health conditions and impairments | the disabled |
| person without a disability; non-disabled | normal person; healthy person; able-bodied |
| blind person; partially sighted person; person with a visual impairment / low vision | sight challenged; vision-impaired |
| select | click (в инструкциях — глаголы, работающие для любого способа ввода) |

Короткие абзацы, одна мысль-глагол на предложение, текст «читается вслух» (screen reader). Писать словами and, plus, about — не символами &, +, ~.

## 6. Пунктуация

### Тире и дефис
- **Hyphen (-)**: составные модификаторы перед существительным — part-time worker, keyword-related ads, third-party solutions; ставить, даже если в источнике нет. После существительного — без дефиса (the file is up to date). Не дефисить наречия на -ly (personally identifying information). Приставки: re- перед e/u (re-entry, re-examine), иначе слитно (reorder, reuse); пары-исключения re-cover/recover, re-sign/resign и т.п.
- **En dash (–)**: минус (с пробелами) и диапазоны чисел (без пробелов). UK предпочитает en dash с пробелами там, где US ставит em dash: «This is an example – and must be taken into account – …». Двойное «--» не использовать.
- **Em dash (—)**: только для выделения изолированного/несущественного элемента; в UK-текстах практически не нужен.

### Запятые
- Без оксфордской запятой: «bug fixes, patches and enhanced functions».
- Перед but запятая не ставится («…on OneDrive but won't be able to…»); ставится, только если части — самостоятельные предложения.
- Перед etc. и после i.e. запятая не ставится: «(i.e. "Last seven days", "Last thirty days" etc.)».

### Кавычки
- Двойные кавычки — норма и для UK.
- Знак препинания — СНАРУЖИ кавычек: Click "Edit Profile". Исключения: знак принадлежит цитате («Forgot password?») и прямая речь («…,» said John).
- Кавычки вокруг терминов кода из US-строк → одинарные (inverted commas).

### Прочее
- Двоеточие: вводит список или пояснение; после двоеточия внутри предложения — строчная буква (кроме имён собственных и после «Note:» / «Important:»).
- Многоточие: избегать; если есть — без пробела до, с пробелом после.
- Восклицательный знак: избегать, особенно в UI-строках.
- Скобки: точка после закрывающей, если внутри фрагмент предложения; внутри — если целое предложение. Пробелов внутри скобок нет.
- Апостроф: никогда не для множественного числа (PCs, CVs, 1990s, to-dos); имена на -s → Niklas's.
- В лейблах пунктуацию не добавлять.
- Притяжательное 's к названиям продуктов/брендов не присоединять — «of construction» или название как прилагательное.

## 7. Сокращения, числа, символы

Аббревиатуры: Art. (article), Chap. (chapter), e.g., h (hour), min (minute), no. (number). В UI следовать источнику; сокращение должно быть понятно в контексте.

Акронимы: международные (DNS, HTML) оставлять; локальные органы заменять на UK-эквивалент (ED → DfE); незнакомый US-акроним при первом употреблении раскрывать: Environmental Protection Agency (EPA).

Числа: от one до nine — словами, свыше девяти — цифрами; при смешении в одном контексте — все цифрами. Неразрывный пробел между числом и единицей (60 ml, 100 mph). «#» не использовать: #586 → No. 586.

## 8. Клавиши и шорткаты, регистр

- Названия клавиш — обычным текстом, не капителью.
- Клавиши-стрелки: отдельно или в комбинации — с заглавной (Up, Down, Ctrl+Left); со словом «arrow» — строчными (right arrow).
- Access key: буква с Alt (H&ome); shortcut key: Ctrl+буква, F1–F12; key tip — символ после «`». Шорткаты en-GB совпадают с en-US (Ctrl+N, Ctrl+S, Alt+F4…) — не менять.
- Заголовки/подзаголовки — sentence case: только первое слово и имена собственные с заглавной («Universal declaration of the rights of man»). Меню, кнопки, лейблы — регистр как в источнике.
- Списки: вводить заголовком или фрагментом с двоеточием; пункты-фрагменты — со строчной и без точки; полные предложения — с заглавной и точкой; при смешении — всё с заглавной и точкой.

## 9. Грамматика: глаголы

- Simple tenses. Simple present по умолчанию: «After you finish installing the tool, the icon appears on your desktop». Future — только про реальное будущее. Simple past — про случившееся.
- Переходные глаголы требуют объекта/пассива: «Choose when the ad will be shown» (не «will show»); «A dialog box appears» (не «displays»); «This document cannot be printed» (не «will not print»); «Your file will be downloaded shortly».
- Нерегулярные UK-формы: learnt, spoilt.
- Split infinitive допустим, если звучит естественнее («to boldly go»).
- Subjunctive не форсировать; напыщенные обороты (be that as it may, were it not for) — избегать.
- Бренды не глаголы: не «Skype your friends».
- Идиомы источника: заменять UK-идиомой только при идеальном совпадении; иначе переводить смысл или опускать, если смысл не страдает.
- Притяжательные (your, its) вместо артиклей — текст естественнее.

## 10. UK-лексика и предлоги

Spelling: favourite, centre, optimise, colour, personalise.

| en-US | en-GB |
|---|---|
| cell phone | mobile phone |
| mall | shopping centre |
| movie theater | cinema |
| state (в адресе) | county (по контексту) |

| en-US | en-GB |
|---|---|
| Monday through Wednesday | Monday to Wednesday |
| finish up | finish |
| waiting on | waiting for |
| different than | different to |
| call us at | call us on |

Начинать/заканчивать предложение предлогом — можно («the apps they are looking for»).

URL: если есть локальный сайт — вести на него (.co.uk или en-gb в пути).

## 11. Copilot-промты (предустановленные промты AI)

- Промт — функциональный текст: точный, единообразный, краткий, естественный; качество влияет на ответ AI.
- Ясность и конкретика: вопрос или просьба с глагола действия, без расплывчатости.
- Разговорно (Microsoft voice), вежливо и профессионально, без сленга и жаргона.
- Кавычки помогают AI понять, что писать/менять.
- Entity-токены (`<entity type='file'>file</entity>`) и плейсхолдеры не локализуются; позиция токена должна быть грамматична. Исключение: display-текст с DevComment «Translate [file]» — переводить.
- Похожие промты переводить единообразно.
- en-GB правки: пунктуация и spelling — «List ideas for a fun, remote team-building event»; «…summarising key takeaways…»; «<placeholder>colour names…».
