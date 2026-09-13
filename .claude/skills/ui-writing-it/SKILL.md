---
name: ui-writing-it
description: "Написание и рефакторинг пользовательских текстов на итальянском — строки интерфейса, кнопки, меню, сообщения об ошибках, тосты, пуши, онбординг, e-mail, описания для App Store и Google Play, Copilot-промты. Применять при любой задаче, где пользователь увидит итальянский текст: «переведи на итальянский», «напиши по-итальянски», «поправь it-строки», ревью или рефакторинг локализации it/it-IT — даже если слово «локализация» в запросе не звучит. Основан на Microsoft Italian Localization Style Guide."
---

# UI-тексты на итальянском

Голос: тепло и естественно, коротко и ясно, на стороне пользователя.
Не переводи дословно — переписывай, как носитель написал бы с нуля; лишнее выбрасывай.

## Порядок работы

1. Определи тип текста:
   - **UI-строка** (кнопка, меню, ошибка, тост, пуш) — минимум слов, императив на «tu».
   - **Длинный текст** (онбординг, стор, письмо, справка) — короткие обычные предложения, тот же тон.
   - **Промт** (готовые подсказки для ИИ) — раздел Copilot в references.
2. Рефакторинг делай батчами: таблица `key | было | стало | почему`; «почему» — одно правило в двух словах.
3. Хорошие строки не трогай: в «стало» пиши OK.
4. Сохраняй плейсхолдеры (%s, %d, {0}, `<entity>`) и их синтаксическую позицию; текст вокруг них держи нейтральным по роду и числу: Non è possibile utilizzare %s.
5. Длина ±30 % от исходника; кнопки и пункты меню — не длиннее оригинала.
6. Таблицы лексики, ошибок, пунктуации, клавиш и Copilot — в `references/ms-style-it.md`. Устоявшиеся термины сверяй с Microsoft Terminology, свои не изобретай.

## Тон и грамматика (из гайда)

- Обращение — «tu» во всех пользовательских текстах: Vuoi continuare? · Prova di nuovo · Dai al tuo PC il nome che preferisci. От лица продукта — «noi»: Riprenderemo da dove eravamo rimasti. Безличный инфинитив (Selezionare un file, È possibile…) — только техдокументация и системный уровень.
- Императив вместо описаний: fai clic su Annulla · disattiva il contrasto elevato.
- Глагол вместо отглагольного и пассива: Stai per rimuovere il documento. Vuoi continuare? — а не Il documento verrà rimosso. Continuare? Пассив допустим как приём гендер-нейтральности.
- Простое настоящее время; будущее — только о реальном будущем.
- Бытовая лексика вместо формальной: vedere, volere, riuscire — не fare riferimento a, desiderare, essere in grado di.
- Притяжательные опускай (кроме маркетинга): …adattare il testo attorno all'immagine, а не il tuo testo.
- Местоимений меньше, чем в английском: …selezionarlo e fare clic su Elimina.
- Фрагменты предложений допустимы для живости: Ecco come. · Di seguito, alcuni dettagli.
- Congiuntivo в письменной речи обязателен: Sarei contento se venissi (не «se vieni»).

## Регистр

- Заголовки, UI-элементы, фичи — sentence case: Impostazione delle opzioni della stampante · il menu File · Modifica filmato.
- Дни, месяцы, языки, валюты, национальности — со строчной: lunedì, giugno, italiano.
- Пары команд через слэш — обе с заглавной: Importa/Esporta file.
- Названия клавиш — капсом: INVIO, ESC, CTRL+MAIUSC.

## Тире — анти-AI-правило

Em dash (—) в итальянском запрещён полностью (прямое требование гайда).
- Вставки и пояснения — запятыми, часто через ovvero: L'account corrente, ovvero quello usato per l'accesso, …
- Конструкции «X — non solo Y» и парцелляцию через тире не писать вообще; перестраивай: Copilot è molto più di un assistente.
- Дефис с пробелами — только разделитель в заголовках: Database - Concetti essenziali.
- En dash — минус и диапазоны чисел: -20°, (0-1).

## Гендер-нейтральность

- l'utente нейтральнее, чем un utente; persone вместо uomini e donne.
- Приёмы: chi + глагол (chi si iscrive), собирательные (il personale, il team), перефраз (Benvenuto → Ti diamo il benvenuto), пассив или безличная форма.
- Расширенный мужской род допустим, когда иначе громоздко или двусмысленно — норма для коротких UI-строк.
- Никаких *, ə и суффиксов через слэш (ragazzo/a); слэш только в бланках: Firma del/della richiedente.

## Ошибки

- По-человечески, без паники и без робота: La password non è corretta. Prova di nuovo. · C'è un problema. Non trovo i file scaricati.
- Продукт — не подлежащее: Non è possibile aprire il documento (не «Word non può aprire…»); для сложных продуктов: Data Protection Manager: non è possibile copiare i file…
- Cannot / Failed to → Non è possibile… («Impossibile…» избегать); essere и potere в коротких ошибках опускай: Funzione non supportata.

## Чек перед сдачей

- Ни одного «—»; вставки запятыми.
- Sentence case в заголовках и UI; клавиши капсом.
- «tu», императив, никаких fare riferimento a / desiderare / essere in grado di.
- Плейсхолдеры на месте, длина в норме, термины по Microsoft Terminology.
