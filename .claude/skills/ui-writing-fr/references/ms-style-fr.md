# Microsoft fr-FR Style Guide — дистилляция

Источник: Microsoft French (France) Localization Style Guide. Только то, что есть в PDF.

## 1. Канцелярит → разговорные слова (words and phrases to avoid)

| Формально (избегать) | Microsoft voice |
|---|---|
| invariablement | toujours |
| il est (fort) probable que | sans doute, probablement |
| pléthore | trop, beaucoup |
| diminution | baisse |
| afin de, dans le but de | pour |
| avoir la possibilité de, avoir l'opportunité de | pouvoir |
| réaliser | faire, effectuer |
| requérir, exiger | demander, nécessiter |
| nécessiter | devoir |
| faire une recommandation | recommander, conseiller |
| impossible de… (в значении «we were unable to») | Nous n'avons pas pu… |

Избегать безличных форм: **on, il y a, il faut, c'est**. Не пиши слов, которые не сказал бы человеку вслух.

## 2. Формальные союзы и предлоги → разговорные

| Формально | Разговорно |
|---|---|
| de même que | comme |
| lors de | durant, pendant |
| auquel cas | не использовать вовсе |
| lorsque, une fois que | quand |
| de sorte que, de (telle) façon que | pour, afin de |
| sitôt que | dès que |
| par conséquent, d'où | ainsi |
| parce que, vu que, à cause de | car |
| jusqu'au moment où | jusqu'à ce que |
| en dépit de | malgré |
| sauf que | sauf si |
| après que, maintenant que | une fois…, une fois que |
| sans ça, sans cela | sinon |

Начинать фразу с союза или предлога — можно, это разговорный тон. `Dû à` в начале фразы — ошибка, только `En raison de…`. `Spécifique à` — ошибка: `propre à / spécifique de`.

## 3. Короткие бытовые слова (short word forms)

| EN | fr-FR |
|---|---|
| app | **application** (полная форма); «appli» — только если в источнике короткая форма и мало места. Никогда «app» |
| info | полная форма **informations** в бегущем тексте; «infos» допустимо при нехватке места и для контактных данных |
| PC | **PC** — как в источнике, одобренный перевод |
| sync | **synchroniser / synchronisation** — никогда «sync», «synchro» |

В целом: в французском предпочтительны полные формы, сокращения — исключение.

## 4. Сообщения об ошибках

Точка в конце ошибки **всегда** — есть спрягаемый глагол или нет. Исключение: строка кончается плейсхолдером — тогда пунктуация как в источнике. Скобок избегать. Тон эмпатичный, не роботский.

Стандартные фразы (стандартизируй, бери простейший вариант):

| EN | fr-FR | Не так |
|---|---|---|
| Cannot… / Could not… | Impossible de télécharger le fichier. | Le fichier ne peut pas être téléchargé. |
| Failed to… / Failure of… | Échec du téléchargement du fichier. | Le téléchargement du fichier a échoué. |
| Cannot find… / Unable to locate… | Fichier introuvable. | Impossible de trouver le fichier. |
| Not enough memory / Insufficient memory | Mémoire insuffisante. | Pas assez de mémoire disponible. |
| …is not available / unavailable | Le fichier n'est pas disponible. | Le fichier est indisponible. |

Примеры тона: `Le mot de passe est incorrect, réessayez. Les mots de passe respectent la casse.` · `Il y a eu un problème : impossible de trouver les fichiers téléchargés…` (здесь «impossible de» — про систему, не «нам не удалось»).

Плейсхолдеры: `%d, %ld, %u, %lu` = число; `%c` = буква; `%s` = строка. Выясняй, что подставится, чтобы грамматика осталась корректной.

## 5. Гендер-нейтральность и инклюзивность

| Использовать | Не использовать |
|---|---|
| principal / secondaire | maître / esclave |
| expert, spécialiste | gourou |
| collègues, tout le monde | mesdames et messieurs |
| parent(s), parente(s) | père ou mère |
| êtres humains, humanité | Hommes |
| effectif, personnel, main-d'œuvre | hommes |
| individu | bonhomme |
| plongeur | homme-grenouille |
| personne en situation de handicap, personne handicapée | un handicapé, une handicapée |
| personne ne présentant pas de handicap, personne valide | personne normale, personne en bonne santé |

Приёмы дегендеризации: эпицены (élève, membre, fonctionnaire), собирательные (la direction вместо les directeurs et les directrices), множественное число (`Les utilisateurs … peuvent définir…` вместо `Si l'utilisateur … il peut…`), артикль вместо притяжательного (le document, не son document), роль (personnel, clientèle), personne / individu. Феминизация профессий для реальных людей — да (auteure/autrice). Реальный человек — его местоимения (il, elle, iel). Обращение к пользователю — мужской род: `Vous êtes connecté.` Продукт/бренд как субъект — без рода: `Quels seraient les avantages pour Microsoft ?` Не «souffrant de», не «touché par».

## 6. Пунктуация

- **Em dash (—):** только для изолированной вставки; в UI заменяй запятой, двоеточием, точкой или скобками. `Bold—Applies bold formatting` → `Gras : met le texte en gras.`
- **En dash (–):** минус (`Salaire – 1 000 = 2 000`, с пробелами) и диапазоны (без пробелов: 10–12).
- **Дефис:** составные слова, инверсии (`voulez-vous`); неразрывный дефис — CTRL+SHIFT+HYPHEN.
- **Точка с запятой:** не использовать. Две короткие фразы лучше. Только длинные перечисления и независимые предложения.
- **Восклицательный знак:** не переносить из источника автоматически — подбирай более сильные слова.
- **Вопросительный знак:** умеренно; хорош, когда ссылка — вопрос клиента.
- **Скобки:** для «заметного шёпота»; в ошибках избегать. `le ou les périphériques`, а не `le(s) périphérique(s)` (в UI при нехватке места скобочное мн. число допустимо).
- **Двоеточие:** вводит списки и объяснения; не для одного элемента (`Cliquez sur Fichier.`, не `Cliquez sur : Fichier.`). После двоеточия строчная буква (кроме заголовка или полной цитаты).
- **Кавычки:** французские « » с неразрывными пробелами внутри. Английские "…" — только в коде, dev-доках и вложенных цитатах (''…''). Кавычки вокруг названий UI-элементов из источника убирать: `Cliquez sur le bouton Supprimer` (без кавычек).
- **Многоточие:** символ … (не три точки). После «etc.» — не ставить.
- **Точка:** одна после точки — один пробел. Полное предложение в скобках — точка внутри; часть предложения — снаружи. Строка без спрягаемого глагола — без точки (`Suppression de fichiers`), кроме ошибок.
- **Неразрывный пробел (nbsp):** обязателен перед `; ! : ?`, перед `%`, между числом и единицей/валютой (`5 000 €`), как разделитель тысяч, после «chapitre/annexe» перед номером (`Chapitre 1 : Installation`).
- **Запятая в перечислении:** без запятой перед et/ou/ni при однородных членах; с запятой — если функции разные.
- **Апострофы:** типографские ’ (curly), прямые — только по требованию разработчика.
- **Списки-буллеты:** полные предложения — с заглавной и точкой; продолжения вводной фразы — с заглавной, без конечного знака. Структура пунктов единообразная (все — существительные, все — инфинитивы или все — предложения).

## 7. Сокращения, числа, плейсхолдеры с числами

- Сокращения: 1er, 1re, 2e, 3e · art. · cf. · chap. · etc. · ex. · Go · h · kHz · Mme · Mlle · M. · Mio · min · no · réf. no. Сокращать после согласной; мн. число без «s» (**des URL, 200 Mo, des PC**).
- Фраза кончается сокращением с точкой — вторая точка не ставится.
- Числа: 0–9 прописью (`cinq à dix minutes`), 10+ цифрами (`11 secondes`); цифры всегда, если число — данные.
- Версии: всегда с точкой (Version 4.2).
- Заголовки-действия — через существительное: `Utilisation de Microsoft Office`.
- Названия продуктов/фич без перевода — без артикля (`Télécharger Microsoft Office`); переведённые фичи — с артиклем (`une carte cadeau Microsoft`).
- Акронимы: капсом без точек, мн. число не меняется; локализованные берут род первого существительного (la PAO, le SGBD); нелокализованные при первом упоминании: полное французское название (АКРОНИМ, *английская расшифровка курсивом*).

## 8. Клавиши и шорткаты, регистр

| EN | fr-FR |
|---|---|
| Backspace | Retour arrière |
| Caps lock | Verr maj |
| Ctrl | Control |
| Delete | Suppr |
| Enter | Entrée |
| Esc | Échap |
| Home | Origine |
| Insert | Inser |
| Num lock | Verr Num |
| Page down / up | Pg suiv / Pg préc |
| Shift | Maj |
| Spacebar | Barre d'espace |
| Arrows | Haut / Bas / Gauche / Droite |
| Print screen | Impr. Écran |
| Scroll lock | Arrêt défil |

Отличающиеся шорткаты: Gras **Ctrl+G** (не Ctrl+B) · Aligné à gauche **Ctrl+Maj+G** · Aligné à droite **Ctrl+Maj+D** · Atteindre **Ctrl+B** · Edition Effacer **Suppr** · Menu **Alt** (не F10) · Gestionnaire des tâches **Ctrl+Maj+Suppr**. Access key в локализации: `H&ome`; key tip — символ после «`». Не назначай access keys на буквы с акцентами (é, à, î) и нижними выносами (g, j, p, q), если есть другие. Дубли допустимы, если букв не хватает.

## 9. Copilot-промты (predefined prompts)

- Пользователь обращается к ИИ на **tu** (2-е лицо ед. ч.): `Donne-moi des idées…`, `Crée une liste…`, `Propose une nouvelle introduction…`.
- Естественные вопросы/просьбы, без vague-формулировок, без сленга и жаргона; вежливо и профессионально.
- Кавычки — chevrons « » с nbsp внутри.
- **Entity tokens**: текст внутри тега переводить, атрибут — нет: `<entity type='file'>fichier</entity>`, `[fichier]`.
- **Ghost text** (`<placeholder>…</placeholder>`) — ставить в конец фразы, чтобы пользователь не двигал курсор в середину.
- Похожие промты переводить единообразно; следить за пунктуацией и регистром.

## 10. Разное из синтаксиса

- Анаколуф из английского чинить: вводить субъект во второй фразе (`Une fois cette dernière installée, l'utilisateur peut…`).
- «According to / depending on» ≠ `Selon…` с той же структурой: `Si vous disposez des droits d'accès adéquats, vous pourrez…` (после «selon» читатель ждёт минимум два варианта).
- Split infinitive не переводить буквально: `We expect our output to more than double` → `nos résultats devraient doubler, au minimum`.
- Разговорные идиомы источника: перевести смысл, подобрать естественный французский вариант или опустить (`Bummer… Delete.` — не переводить; `Drum roll…` → `Fin de l'installation`).
