# Microsoft Style Guide pt-BR — дистилляция

Источник: Microsoft Portuguese (Brazil) Localization Style Guide. Только то, что реально нужно для UI-текстов.

## 1. Канцелярит и формальные слова → предпочтительные

| Избегать | Использовать | Комментарий |
|---|---|---|
| ser capaz de | poder | «to be able to» |
| subsequente | seguinte | |
| quaisquer | *(опустить местоимение)* | «any» чаще всего не переводится |
| consulte | veja | при отсылке к справке/странице |
| consulte | confira | когда предлагаем «зацени, посмотри» (офферы, интересный контент) |

Синонимы для разнообразия (взаимозаменяемы, второй вариант — разговорнее):

| en-US | Нейтральный | Разговорный |
|---|---|---|
| select | selecionar | escolher (в лёгких контекстах: «escolha uma cor»; selecionar — для формальных) |
| find | localizar | encontrar |
| change | alterar | mudar |
| modify | modificar | mudar |
| access | acessar | visitar (о веб-страницах) |
| support | suportar | ser compatível, permitir |
| view | visualizar | ver |
| search | pesquisar | procurar |

## 2. Дословный перевод → живой текст (принципы)

- Не переводи слово в слово: сокращай, дели фразы, выбрасывай необязательные детали.
- «Share your memories» → «Compartilhe suas fotos» (конкретика вместо метафоры).
- «Movie-making magic» → «Faça filmes incríveis» (глагол вместо «магии»).
- Опускай хвосты вроде «with others», «Tap for details», «follow a few more steps and then you're ready to go», если смысл не теряется.
- Идиомы: не подбирай бразильский аналог насильно; переводи смысл или опускай («It's lonely in here» → «Não há nada aqui»).

## 3. Стандартные фразы ошибок

| en-US паттерн | pt-BR | Примечания |
|---|---|---|
| Cannot… / Could not… | Não é possível + infinitivo | если важно прошедшее время: Não foi possível |
| Failed to… / Failure of… | Falha ao… | глагол failed в середине фразы: sujeito + não pôde + complemento («A instalação não pôde ser inicializada») |
| …occurred / …has occurred | *(опустить)* | «Erro de disco durante uma operação de leitura.» |
| Not enough / insufficient memory | …insuficiente | «Memória insuficiente para…» |
| …is not available / unavailable | …não disponível | глагол-связку опускать: «Site não disponível» |

Стиль ошибок:
- Всегда **sentence case**, даже если в источнике Title Case: «Falha ao salvar o arquivo na Biblioteca de Ativos».
- Ясность: делить длинную фразу на две, резать придаточные. «Since a virus was detected, rebooting is recommended…» → «Vírus detectado. É aconselhável reinicializar o computador para minimizar possíveis danos.»
- Экономия: «This file could not be found.» → «Arquivo não encontrado.»
- Дружелюбно, не по-роботски: «A senha está incorreta. Tente novamente. Senhas diferenciam maiúsculas de minúsculas.»

## 4. Гендер-нейтральность и инклюзивность

| Использовать | Не использовать |
|---|---|
| a humanidade | o homem |
| a classe política | os políticos |
| o corpo docente | os professores |
| estudantes | alunos |
| a coordenação | os coordenadores |
| pessoas, colegas, homens e mulheres | rapazes, rapaziada, guys |
| primário/subordinado | mestre/escravo |
| parar de responder | ficar mudo |
| especialista | guru |
| pessoa com deficiência | deficiente |
| pessoa sem deficiência | pessoa normal, pessoa saudável |

Приёмы:
- Множественное число для обобщений: «Usuários … poderão definir…», а не «O usuário … pode…».
- Никаких ele/ela/dele/dela в generic-референсах и никаких «ele(a)». Перестраивай: você, plural (eles), артикль вместо притяжательного (o documento вместо o documento dele), «o nome da pessoa» вместо «o nome dele».
- Вместо ролей в м.р. — собирательные: a coordenação вместо o coordenador; или ninguém/pessoa/indivíduo.
- Пассив/императив/инфинитив вместо гендерного подлежащего: «Envie o pedido até sábado» вместо «O candidato deve enviar…».
- О реальных людях — местоимения, которые человек сам использует.
- Не acometido / sofrendo de algo; инвалидность не упоминать, если не релевантна.
- Доступность: глаголы, работающие для любого способа ввода — Selecione, а не Clique. Одна фраза — один глагол. Писать словами e, mais, cerca de (не &, +, ~) — скринридеры.

## 5. Пунктуация

- **Запятая**: НЕ ставится перед e, ou, nem между последними элементами перечня: «emails, contatos, calendários e tarefas».
- **Двоеточие**: после него — строчная буква: «OBSERVAÇÃO: esta compra…».
- **Em dash (—)**: только для выделения изолированного/несущественного элемента; в UI — фактически не использовать (см. анти-AI правило в SKILL.md).
- **En dash (–)**: минус и числовые диапазоны (seções A–E).
- **Дефис**: по орфографическим правилам pt-BR.
- **Кавычки**: следуй источнику ("Mostrar IDs disponíveis").
- **Многоточие**: следуй источнику, отдельных правил нет.
- **Точка**: без двойных пробелов после точки. В UI-строках конечные точки — как в источнике (строки склеиваются в рантайме). В маркированных списках: полное предложение — с точкой, фрагмент — без.
- **Скобки**: без пробелов внутри: (texto).
- Если фраза кончается аббревиатурой с точкой — вторая точка не ставится.

## 6. Сокращения, числа, плейсхолдеры

Сокращения — крайняя мера при нехватке места:
- Оканчиваются на согласную (искл.: ago., dra., profa., sra.).
- Диакритика сохраняется; множественное — +s (кроме единиц измерения).
- Частые: artigo → art., feminino → fem., masculino → masc., século → séc.
- Точка убирается, если может быть понята неверно (макросы, команды).

Числа:
- 1–10 — словами, дальше цифрами.
- Круглые большие: mil, quatro milhões, 16 bilhões.
- В технических текстах, лейблах, заголовках, маркетинге — цифрами.
- Version 4.2 → Versão 4.2 (точка в номере версии всегда).

Плейсхолдеры:
- %d, %ld, %u, %lu = число; %c = буква; %s = строка. Выясни, что подставится, и согласуй грамматику; двигай плейсхолдер по фразе как обычное слово.
- Плейсхолдер-название продукта — с определённым артиклем: «O <a> salvará…».
- Неразрывный пробел: между capítulo/apêndice и номером, числом и единицей, внутри имён вроде Microsoft Office (но не в онлайн-справке).

## 7. Акронимы и названия

- Технические акронимы (API, EFI…) не переводятся; при первом появлении — локализованная расшифровка в скобках ПОСЛЕ акронима, дальше только акроним. В тесном UI можно без расшифровки.
- Форматы файлов и протоколы: formato GIF, formato JPEG — без расшифровки. USB, HDMI, ISO — как есть.
- Множественное: os PCs; род заимствований — по узусу (o PC, a URL, o site, a home page, o widget).
- Названия продуктов Microsoft — как в источнике; предлог в названии переводится (CRM para Outlook). «Microsoft Corporation» и «All rights reserved» — по терминологии MS.
- Учитывай аудиторию: для Office-пользователя лучше «lista de controle de acesso», чем «ACL»; внутри продукта — единообразие.

## 8. Клавиши и шорткаты

Локализуемые названия клавиш (остальные — как в en):

| en-US | pt-BR |
|---|---|
| Ctrl | Control |
| Down/Up Arrow | Seta para baixo / Seta para cima |
| Left/Right Arrow | Seta para a esquerda / Seta para a direita |
| Spacebar | Barra de espaços |
| Windows key / Menu key | Tecla Windows / Tecla Menu |

Отличающиеся стандартные шорткаты (меню Файл/Правка локализованы!):

| Команда | en-US | pt-BR |
|---|---|---|
| Novo | Ctrl+N | Ctrl+O |
| Abrir | Ctrl+O | Ctrl+A |
| Salvar | Ctrl+S | Ctrl+B |
| Selecionar Tudo | Ctrl+A | Ctrl+T |
| Localizar | Ctrl+F | Ctrl+L |
| Negrito | Ctrl+B | Ctrl+N |

Регистр названий клавиш — обычный текст, не капс. Access keys: буква для шортката — первая буква первого/второго слова, потом вторая и т.д.; «узкие» буквы (i, l, t) и буквы с хвостами (g, j, p) — только если ничего другого нет.

## 9. Copilot-промты (предзаданные подсказки для AI)

- Промты функциональны: точность перевода влияет на качество ответа AI.
- Ясность и конкретика: естественный вопрос или просьба с глаголом действия, без размытых слов.
- Разговорно, но вежливо и профессионально; без сленга и жаргона, без «машинного» тона.
- Кавычки сохранять — они говорят Copilot, что выделить/заменить: «Realce em amarelo todas as menções de "Microsoft"».
- Entity-токены (<entity type='file'>…</entity>, [file]) не локализуются и ставятся туда, где это грамматично в pt-BR. Исключение: если промт — display-текст и DevComment велит переводить ([file] → [arquivo]).
- Похожие английские промты переводить единообразно.
- Примеры: «List ideas for a fun remote team building event» → «Liste ideias para um evento divertido de criação de equipe remota»; «Give me ideas for icebreaker activities for a new team» → «Dê ideias de atividades para quebrar o gelo com uma nova equipe».
