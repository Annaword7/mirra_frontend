# Microsoft Spanish (Neutral) — дистилляция стайлгайда для UI-текстов

Сжатая выжимка таблиц из официального Microsoft Spanish (Neutral) Style Guide.
Раздела про Copilot-промты в PDF нет — поэтому его здесь нет.

## 1. Канцелярит и формальные слова → предпочтительные

| Избегать | Использовать | Контекст (en-US) |
|---|---|---|
| (cuando sea) apropiado | (cuando) corresponda / sea posible / se pueda | (when) appropriate |
| y, a continuación,… | y después… / y luego… | …and then… |
| acerca de | sobre | about |
| siempre y cuando… | si… | as long as |
| solicitar / requerir | pedir | ask for, request |
| detectar (un error) | encontrar (un error) | detect |
| realice los siguientes pasos… | haz lo siguiente… | follow these steps |
| sin embargo / no obstante | pero | however |
| si ya has permitido… | si ya permitiste… | if you've already allowed |
| asimismo,… | además,… / también,… | in addition |
| junto con | con | in conjunction with |
| suministrar / proporcionar | dar | provide |
| volver a instalar | reinstalar | reinstall |
| subsiguiente | siguiente / que sigue a… | subsequent |
| tener la oportunidad de | poder | to have the opportunity to |
| intentar | tratar | try |
| inténtelo de nuevo | prueba otra vez / volver a intentarlo | try again |

## 2. Формальные конструкции → разговорные

- Составные времена → простые: «después de haber terminado» → «después de que termines».
- Длинные предложные обороты → простые предлоги: «a través de la vista de diseño» → «con/en la vista de diseño».
- Начинать предложение с союза можно: «Y, por último…», «O sea que…», «Además,…».
- «desear» → «querer» («¿Quieres continuar?»); «utilizar» → «usar».
- Синонимы для живости (кроме цитат UI-элементов): puntear → pulsar; funcionalidad → características, funciones; purgar → depurar, limpiar, eliminar; iniciar → empezar; cancelar → anular (последние два — не как названия UI-команд).
- «please» при переводе опускается: «Prueba otra vez», без «por favor».

## 3. Короткие бытовые формы слов

| Полная форма | Короткая | Примечание |
|---|---|---|
| demostración | demo | есть в словаре RAE |
| gigabyte | giga / GB | после числа: «necesitarás 2 gigas» |
| cuenta de correo electrónico | cuenta de correo | полная форма слишком длинная |
| mensaje de correo electrónico | mensaje de correo / mensaje | если контекст ясен |
| — | PC | всегда «tu PC / tus PC», без рода; если род неизбежен — «equipo» |

«app» и «info» короткой испанской формы не имеют — писать полные слова (aplicación, información).

## 4. Ошибки (error messages)

Стиль: коротко, номинально, без роботизированности; эмпатия допустима («¡Uy! Esto no puede estar en blanco…»).

- Разделитель частей сообщения — **точка** (не `;` и не `:`): «Disco lleno. No se puede guardar el archivo.»
- Восклицательные знаки источника не переносить: «Operation failed!» → «No se pudo realizar la operación.»
- Глагол ser/estar в коротких фразах опускается: «Comando no disponible.», «Dispositivo especificado no válido.» В длинных фразах с причастиями — глагольная структура.
- Безличная форма предпочтительнее повторов «tú»; субъект указывать, когда называется причина ошибки.

Стандартные формулы:

| en-US | es | Примечание |
|---|---|---|
| Cannot… / Unable to… | No se puede + inf. | акцент на действии |
| Could not… (прошлое) | No se pudo + inf. | |
| …failed / Failure of… | Error + предлог («Error en la conexión.») | не «fallo/falló» |
| …failed to… | sujeto + no se pudo + compl. («La instalación no se pudo inicializar.») | |
| …occurred / has occurred | опустить: «Error de escritura.» | не «ha ocurrido», не «ocurrió» |
| Not enough / Insufficient… | …insuficiente («Memoria insuficiente para…») | |
| …is not available | …no disponible | глагол опускается |
| …not found | No se encuentra… | |

Плейсхолдеры: `%d %ld %u %lu` = число, `%c` = буква, `%s` = строка; трактовать как обычное слово и ставить в грамматичную позицию.

## 5. Гендер-нейтральность и инклюзивность

| Не так | Так |
|---|---|
| jefe | responsable |
| el hombre (humanity) | humanidad |
| vendedor | representante de ventas |
| hecho por el hombre | manufacturado |
| empleados (manpower) | plantilla |

- Не использовать гендерные местоимения в обобщениях; переформулировать во 2-е лицо, множественное число, роль («persona», «cliente»). Конструкции «él/ella», «los/las» — запрещены.
- Аббревиатуры-англицизмы: род по испанскому эквиваленту — **la web** (la red), **la caché** (la memoria), **el firewall** (el servidor).
- Доступность: «Selecciona» вместо «Haz clic»; не упоминать инвалидность без нужды, без слов жалости; писать «y», «más» словами (скринридеры путают `&`, `+`, `~`); одно сказуемое на предложение.

## 6. Пунктуация

- **Raya (—)**: по стайлгайду — только для выделения изолированного, несущественного элемента; в этом скилле в UI **запрещена полностью** (анти-AI правило), заменять запятой/точкой/перестройкой.
- **En dash (–)**: минус (`– 18 °C`, пробел после знака) и диапазоны (`páginas 204–206`, без пробелов).
- **Дефис**: составные слова (`relación calidad-precio`) и переносы.
- **Кавычки**: в текстах Microsoft — “смарт-кавычки” / прямые по источнику; следовать источнику («"Mostrar id. disponibles"»). В техтексте уточнять: sencilla ( ' ) или doble ( " ).
- **Многоточие**: пробел перед ним убирать, даже если есть в источнике («Estamos conectando, espera...»); в ссылках на команду с «…» в меню многоточие не сохранять.
- **Точка**: после точки один пробел, никогда два.
- **Скобки**: без пробелов внутри.
- **¿ ¡**: открывающие знаки обязательны.
- **Двоеточие/запятая**: по нормативной грамматике RAE.
- Списки-буллеты: полные предложения — с заглавной и точкой; продолжения одной фразы — со строчной, с запятыми/`;` и финальной точкой; неполные фразы — без точки.
- Неразрывный пробел: между «capítulo/apéndice» и номером, между числом и единицей/валютой, внутри «Microsoft Office».

## 7. Сокращения

Правила: порядок букв как в слове; опускать минимум 2 символа; усечённые формы не кончаются на гласную (pról., не prólo.); стяжения могут (pdo.); в конце точка; ударение сохраняется, если ударная буква вошла в сокращение. В сплошном тексте лишних сокращений избегать.

Частые: aprox., bibl., cap., cód., dcha., doc., fig., izqda., máx., mín., p. / pág., p. ej., ref.

Акронимы: множественного «-s» нет — число через артикль («los DVD», «unos CD»); широко известные (CD, DVD, IP, DSL, ISO, ANSI) не расшифровывать; малоизвестные — при первом упоминании полное испанское название + (акроним): «…alimentación ininterrumpida (SAI)».

## 8. Числа

- Нетехнический текст: числа в одно-два слова — прописью («unos dieciocho años»), длинные — цифрами.
- Технический/деловой текст и UI: **цифры**, следовать источнику.
- Цифры всегда: даты, адреса, проценты, дроби, десятичные, страницы, ID, время.
- Номер версии всегда с точкой: «versión 1.0».

## 9. Клавиши и шорткаты

Регистр названия клавиши — как в источнике (CTRL ↔ Ctrl). Названия — обычным текстом.

Ключевые: Backspace → Retroceso; Delete → Supr; Enter → Intro (в шорткатах локализовано «Entrar»: Alt+Entrar); Shift → Mayúsculas / Mayús; Caps Lock → Bloq Mayús; Num Lock → Bloq Num; Page Up/Down → Re Pág / Av Pág; Home → Inicio; End → Fin; Esc → Esc; Tab → Tabulación; Spacebar → Barra espaciadora; Arrow keys → Flecha arriba/abajo/izquierda/derecha; Print Screen → Imp Pant; Windows key → tecla Windows.

Шорткаты локализуются: Ctrl+N (New) → Ctrl+U (Nuevo); Ctrl+S (Save) → Ctrl+G (Guardar); Ctrl+F (Find) → Ctrl+B (Buscar); Ctrl+A (Select All) → Ctrl+E; Bold Ctrl+G → Negrita Ctrl+N; Italic Ctrl+I → Cursiva Ctrl+K. Access keys: расширенные символы, цифры/буквы в скобках после названия — нельзя; узкие буквы (i, l, t) и буквы с нижними выносами (g, j, p) — только если нет альтернативы; консистентность по продукту, ориентир — Office/Windows.

## 10. Обращение по продуктам (tú/usted)

- **tú**: WDG (Windows), Skype, Microsoft Store, Windows Phone, OneNote (Phone/Android), Lync Metro/Phone/Android, весь маркетинг (PMG).
- **usted**: Office (большинство приложений), OneNote (PC/iOS), Lync Rich Client/Server/доки, Exchange, Cloud & Enterprise (Azure, SQL Server, Visual Studio…), Dynamics. Исключение: TechNet для молодой аудитории — tú.

## 11. Разное

- Мастера (wizard): «Asistente para + существительное/инфинитив»; локализованные имена фич с нарицательным словом — с артиклем («el Asistente para informes»), как имя собственное — без.
- Предлог в названии продукта переводится («Visual Studio Ultimate con MSDN»), если нет запрета по трейдмарку.
- Не координировать глаголы с разными предлогами при общем дополнении («enviado a y recibido de» — нельзя).
- Queísmo/dequeísmo: «Asegúrate **de que**…», «Es posible **que**…».
- Идиомы источника: испанский аналог только при идеальном совпадении; иначе — перевести смысл или опустить.
- GroupMe: участник группы — «miembro», не «participante».
