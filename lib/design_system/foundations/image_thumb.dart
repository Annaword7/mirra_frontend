/// Загрузка картинок продуктов: уменьшенная версия с сервера + кэш на диске.
///
/// Снимки пользователей лежат в Storage как есть — встречаются PNG по 2.5 МБ,
/// хотя в ленте картинка занимает пол-экрана. Supabase умеет отдавать
/// уменьшённый вариант через `/render/image/`, и с заголовком Accept он
/// возвращает webp: те же 2.5 МБ приезжают как ~36 КБ.
///
/// URL не из нашего Storage (внешние каталожные ссылки) остаются как есть —
/// им доступен только диск-кэш.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

const _objectPath = '/storage/v1/object/public/';
const _renderPath = '/storage/v1/render/image/public/';

/// Заголовок, ради которого Storage отдаёт webp вместо исходного формата.
const Map<String, String> _webpHeaders = {'Accept': 'image/webp,*/*'};

/// Ссылка на уменьшенную версию [url] шириной [width] (в пикселях устройства).
///
/// `resize=contain` обязателен. По умолчанию Storage режет в режиме `cover`, и
/// с одним лишь `width` он понимает запрос как «вписать в рамку width × высота
/// оригинала»: у снимка 4032×3024 это 720×4032 — вертикальная полоса из
/// середины кадра. Именно она приезжала в ленту и в Косметичку, и никакой
/// BoxFit на клиенте её уже не чинит, потому что обрезал сервер.
String thumbUrl(String url, {required int width, int quality = 75}) {
  if (!url.contains(_objectPath)) return url;
  final base = url.replaceFirst(_objectPath, _renderPath);
  final separator = base.contains('?') ? '&' : '?';
  return '$base${separator}width=$width&resize=contain&quality=$quality';
}

/// Провайдер для [url]: уменьшенная версия, webp и кэш на диске между
/// запусками — повторный показ той же карточки идёт без сети.
///
/// [ResizeImage] ограничивает уже распаковку. Это важно для внешних ссылок:
/// их [thumbUrl] не переписывает, сервер отдаёт оригинал, и без предела
/// каталожный снимок разворачивался в память целиком.
ImageProvider thumbProvider(String url, {required int width, int quality = 75}) =>
    ResizeImage(
      CachedNetworkImageProvider(
        thumbUrl(url, width: width, quality: quality),
        headers: _webpHeaders,
      ),
      width: width,
    );
