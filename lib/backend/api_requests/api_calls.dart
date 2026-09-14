import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class CloneimageandparamsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? imageId,
  }) async {
    final ffApiRequestBody = '''
{
  "image_id": ${imageId}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'cloneimageandparams',
      apiUrl:
          'https://pjapsfbztorijypnldam.supabase.co/functions/v1/clone_image_and_params',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class LinkTelegramCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? code = '',
  }) async {
    final ffApiRequestBody = '''
{
  "code": "${code}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'linkTelegram',
      apiUrl:
          'https://pjapsfbztorijypnldam.supabase.co/functions/v1/link-telegram',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? ok(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.ok'''));

  static String? errorCode(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.code'''));
}

class LinkitemtoalbumsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? imageId,
    List<String>? albumIdsList,
  }) async {
    final albumIds = _serializeList(albumIdsList);

    final ffApiRequestBody = '''
{
  "image_id": ${imageId},
  "album_ids": ${albumIds}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'linkitemtoalbums',
      apiUrl:
          'https://pjapsfbztorijypnldam.supabase.co/functions/v1/link_item_to_albums',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AnalyzeingredientsCall {
  static Future<ApiCallResponse> call({
    String? inciString = '',
    String? productName = '',
    int? imageId,
    String? host,
    String? userId = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "inci_string": "${escapeStringForJson(inciString)}",
  "product_name": "${escapeStringForJson(productName)}",
  "image_id": ${imageId},
  "user_id": "${escapeStringForJson(userId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Analyzeingredients',
      apiUrl: '${host}analyze-ingredients',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer dGVzdHVzZXI6aGFzaGQkMTIzNDU2',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static double? score(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.score''',
      ));
  static String? cleandescription(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.clean_description''',
      ));
}

class AnalyzeproductNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? imageId = '',
    String? userId = '',
    String? languageCode = 'en',
    String? country = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "image_id": "${escapeStringForJson(imageId)}",
  "user_id": "${escapeStringForJson(userId)}",
  "language_code": "${escapeStringForJson(languageCode)}",
  "country": "${escapeStringForJson(country)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'analyzeproduct NEW BCND',
      apiUrl: '${host}api/mirra/analyze-product',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
  static String? error(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.error''',
      ));
  static String? resettime(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.reset_time''',
      ));
  static int? limit(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.limit''',
      ));
  static String? details(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.details''',
      ));
}

class SearchingredientsNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? imageId = '',
    String? productName = '',
    String? brand = '',
    String? country = '',
    String? token = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "image_id": "${escapeStringForJson(imageId)}",
  "product_name": "${escapeStringForJson(productName)}",
  "brand": "${escapeStringForJson(brand)}",
  "country": "${escapeStringForJson(country)}"
}''';
    return ApiManager.instance
        .makeApiCall(
          callName: 'searchingredients NEW BCND',
          apiUrl: '${host}api/mirra/search-ingredients',
          callType: ApiCallType.POST,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
          },
          params: {},
          body: ffApiRequestBody,
          bodyType: BodyType.JSON,
          returnBody: true,
          encodeBodyUtf8: false,
          decodeUtf8: false,
          cache: false,
          isStreamingApi: false,
          alwaysAllowBody: false,
        )
        .timeout(
          // Bound the request: the server's own ceiling is gunicorn --timeout 120,
          // so no response by then means the socket is silently stuck. Return the
          // same shape makeApiCall produces on a network error (statusCode -1 ->
          // unmatched status) so the caller's catch-all error branch resets the
          // "Ищем состав" state instead of spinning forever.
          const Duration(seconds: 120),
          onTimeout: () => ApiCallResponse(null, const <String, String>{}, -1),
        );
  }

  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
  static String? error(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.error''',
      ));
  static String? resettime(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.reset_time''',
      ));
  static int? limit(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.limit''',
      ));
  static String? details(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.details''',
      ));
  static String? code(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.code''',
      ));
  static String? ingredientsStatus(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.ingredients_status''',
      ));
}

class SetProductIngredientsCall {
  static Future<ApiCallResponse> call({
    String? host,
    int? imageId,
    String? ingredients = '',
    String? token = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "ingredients": "${escapeStringForJson(ingredients)}",
  "normalize": true
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'set product ingredients',
      apiUrl: '${host}api/mirra/product/${imageId}/ingredients',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SubmitIngredientsPhotoCall {
  static Future<ApiCallResponse> call({
    String? host,
    int? imageId,
    String? photoUrl = '',
    String? token = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "photo_url": "${escapeStringForJson(photoUrl)}"
}''';
    return ApiManager.instance
        .makeApiCall(
          callName: 'submit ingredients photo',
          apiUrl: '${host}api/mirra/product/${imageId}/ingredients-photo',
          callType: ApiCallType.POST,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
          },
          params: {},
          body: ffApiRequestBody,
          bodyType: BodyType.JSON,
          returnBody: true,
          encodeBodyUtf8: false,
          decodeUtf8: false,
          cache: false,
          isStreamingApi: false,
          alwaysAllowBody: false,
        )
        .timeout(
          // GPT-4o Vision OCR takes ~10-20s; bound the wait like the search call.
          const Duration(seconds: 60),
          onTimeout: () => ApiCallResponse(null, const <String, String>{}, -1),
        );
  }

  static String? ingredients(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.ingredients''',
      ));
  static String? code(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.code''',
      ));
}

class ScientificanalysisNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? imageId = '',
    String? userId = '',
    String? languageCode = 'en',
    String? country = '',
    String? token = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "image_id": "${escapeStringForJson(imageId)}",
  "user_id": "${escapeStringForJson(userId)}",
  "language_code": "${escapeStringForJson(languageCode)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'scientificanalysis NEW BCND',
      apiUrl: '${host}api/mirra/scientific-analysis',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? consumersummary(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.analysis.consumer_summary''',
      ));
  static double? compositescore(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.analysis.scores.composite_score''',
      ));
  static String? producttype(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.analysis.product_type''',
      ));
  static double? coveragepercent(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.analysis.coverage_percent''',
      ));
  static String? expertsummary(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.analysis.expert_summary''',
      ));
  static String? productname(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.product_name''',
      ));
  static String? formatteddisplay(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.formatted_display''',
      ));
  static List<String>? bestfor(dynamic response) => (getJsonField(
        response,
        r'''$.analysis.best_for''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? avoidif(dynamic response) => (getJsonField(
        response,
        r'''$.analysis.avoid_if''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static String? errorcode(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.code''',
      ));
}

class FeedbackNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? imageId = '',
    String? userId = '',
    bool? vote,
    String? token = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "image_id": "${escapeStringForJson(imageId)}",
  "user_id": "${escapeStringForJson(userId)}",
  "vote": "${vote}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'feedback NEW BCND',
      apiUrl: '${host}/api/mirra/feedback',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? consumersummary(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.analysis.consumer_summary''',
      ));
  static double? coveragepercent(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.analysis.coverage_percent''',
      ));
  static String? expertsummary(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.analysis.expert_summary''',
      ));
  static String? productname(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.product_name''',
      ));
  static String? formatteddisplay(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.formatted_display''',
      ));
  static List<String>? bestfor(dynamic response) => (getJsonField(
        response,
        r'''$.analysis.best_for''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? avoidif(dynamic response) => (getJsonField(
        response,
        r'''$.analysis.avoid_if''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetimageNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? imageId = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    return ApiManager.instance.makeApiCall(
      callName: 'getimage  NEW BCND',
      apiUrl: '${host}api/mirra/scientific-analysis/${imageId}',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? brand(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.product.brand''',
      ));
  static List<String>? bestfor(dynamic response) => (getJsonField(
        response,
        r'''$.best_for''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static dynamic ingredientcoverage(dynamic response) => getJsonField(
        response,
        r'''$.ingredient_coverage''',
      );
  static double? coveragepercent(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.ingredient_coverage.coverage_percent''',
      ));
  static String? ingredients(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.ingredients''',
      ));
  static double? overallscore(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.overall_score''',
      ));
  static dynamic product(dynamic response) => getJsonField(
        response,
        r'''$.product''',
      );
  static String? name(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.product.name''',
      ));
  static String? ratingtext(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.rating_text''',
      ));
  static List<String>? category(dynamic response) => (getJsonField(
        response,
        r'''$.top_ingredients[:].category''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? concentration(dynamic response) => (getJsonField(
        response,
        r'''$.top_ingredients[:].concentration''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? description(dynamic response) => (getJsonField(
        response,
        r'''$.top_ingredients[:].description''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<double>? efficacycontribution(dynamic response) => (getJsonField(
        response,
        r'''$.top_ingredients[:].efficacy_contribution''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<double>(x))
          .withoutNulls
          .toList();
  static List<String>? ntopingredientsame(dynamic response) => (getJsonField(
        response,
        r'''$.top_ingredients[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<int>? position(dynamic response) => (getJsonField(
        response,
        r'''$.top_ingredients[:].position''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static String? type(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.product.type''',
      ));
  static List? skincompatibility(dynamic response) => getJsonField(
        response,
        r'''$.skin_compatibility''',
        true,
      ) as List?;
  static List<String>? skincompatibilitylabel(dynamic response) =>
      (getJsonField(
        response,
        r'''$.skin_compatibility[:].label''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<int>? skincompatibilityscore(dynamic response) => (getJsonField(
        response,
        r'''$.skin_compatibility[:].score''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<String>? skincompatibilityskintype(dynamic response) =>
      (getJsonField(
        response,
        r'''$.skin_compatibility[:].skin_type''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static String? skincompatibilitysummary(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.summary''',
      ));
  static String? skincompatibilityhowtouse(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.how_to_use''',
      ));
}

class ExtractproductinfoNEWBCNDCopyCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? imageUrl = '',
    String? userId = '',
    String? languageCode = 'en',
    String? country = '',
    String? token = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "image_url": "${escapeStringForJson(imageUrl)}",
  "user_id": "${escapeStringForJson(userId)}",
  "language_code": "${escapeStringForJson(languageCode)}",
  "country": "${escapeStringForJson(country)}",
  "scan_source": "app"
}''';
    return ApiManager.instance
        .makeApiCall(
          callName: 'extractproductinfo NEW BCND Copy',
          apiUrl: '${host}api/mirra/extract-product-info',
          callType: ApiCallType.POST,
          headers: {
            'Authorization': 'Bearer ${token}',
            'Content-Type': 'application/json',
          },
          params: {},
          body: ffApiRequestBody,
          bodyType: BodyType.JSON,
          returnBody: true,
          encodeBodyUtf8: false,
          decodeUtf8: false,
          cache: false,
          isStreamingApi: false,
          alwaysAllowBody: false,
        )
        .timeout(
          // Bound the request: the server's own ceiling is gunicorn --timeout 120,
          // so no response by then means the socket is silently stuck. Return the
          // same shape makeApiCall produces on a network error (statusCode -1 ->
          // succeeded == false) so the caller's existing error branch resets the
          // "Распознаём продукт" state instead of spinning forever.
          const Duration(seconds: 120),
          onTimeout: () => ApiCallResponse(null, const <String, String>{}, -1),
        );
  }

  static String? name(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.product_name''',
      ));
  static String? brand(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.brand''',
      ));
  static int? iamgeID(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.image_id''',
      ));
  static String? langcode(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.language_code''',
      ));

  // Quota fields — only present on 429 SCAN_QUOTA_EXCEEDED responses.
  static int? quotaUsed(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.limit''',
      ));
  static String? resetTime(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.reset_time''',
      ));
  static String? quotaCode(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.code''',
      ));
  static int? remaining(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.remaining''',
      ));
  static String? resetAt(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.reset_at''',
      ));
  static int? retryAfterSeconds(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'''$.retry_after_seconds''',
      ));
}

/// GET /api/mirra/quota — returns the authenticated user's current scan quota state.
/// Reconciles premium with RevenueCat server-side. Called after a purchase and
/// after "restore purchases" so access does not wait on webhook delivery.
/// Takes no body: the backend looks the customer up by the authenticated user.
/// Free-text message from the app into the developer Telegram chat.
///
/// Replaces the old TelegrammessegeCall, which called api.telegram.org directly
/// and therefore needed the bot token compiled into the app bundle. The token
/// now lives only on the backend.
class SendAppMessageCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? token = '',
    String? message = '',
    String? form = '',
    String? email = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "message": "${escapeStringForJson(message)}",
  "form": "${escapeStringForJson(form)}",
  "email": "${escapeStringForJson(email)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sendAppMessage',
      apiUrl: '${host}api/mirra/app-message',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SubscriptionSyncCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? token = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    return ApiManager.instance.makeApiCall(
      callName: 'subscriptionSync',
      apiUrl: '${host}api/mirra/subscription/sync',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: '{}',
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? isPremium(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.is_premium''',
      ));
}

class GetScanQuotaCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? token = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    return ApiManager.instance.makeApiCall(
      callName: 'getScanQuota',
      apiUrl: '${host}api/mirra/quota',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? plan(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.plan''',
      ));
  static bool? isUnlimited(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.is_unlimited''',
      ));
  static int? quotaUsed(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.quota_used''',
      ));
  static int? quotaLimit(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.quota_limit''',
      ));
  static int? remaining(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.remaining''',
      ));
  static String? resetAt(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.reset_at''',
      ));
  static int? retryAfterSeconds(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'''$.retry_after_seconds''',
      ));
}

class CopyproductNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    int? sourceImageId,
    String? targetUserId = '',
    String? token = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "source_image_id": ${sourceImageId},
  "target_user_id": "${escapeStringForJson(targetUserId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'copyproduct NEW BCND',
      apiUrl: '${host}api/mirra/copy-product',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? answer(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
  static int? newimageid(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.new_image_id''',
      ));
}

class ResearchAndAnalyzeCall {
  static Future<ApiCallResponse> call({
    String? host,
    int? imageId,
    String? languageCode = 'en',
    String? token = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "image_id": ${imageId},
  "language_code": "${escapeStringForJson(languageCode)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'research and analyze',
      apiUrl: '${host}api/mirra/research-and-analyze',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SubscriptionupgradeNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    int? durationDays,
    String? userId = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
    "user_id": "${escapeStringForJson(userId)}",
    "duration_days": ${durationDays}
  }''';
    return ApiManager.instance.makeApiCall(
      callName: 'subscriptionupgrade NEW BCND',
      apiUrl: '${host}api/mirra/subscription/upgrade',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? answer(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
}

class SubscriptioncheckNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? userId = '',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
    "user_id": "${escapeStringForJson(userId)}"
  }''';
    return ApiManager.instance.makeApiCall(
      callName: 'subscriptioncheck  NEW BCND',
      apiUrl: '${host}api/mirra/subscription/check',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? remaining(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.remaining''',
      ));
  static bool? allowed(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.allowed''',
      ));
}

class DeleteUserNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? userId = '',
    String? token = '',
    // Keychain-идентичность устройства — user_id в Amplitude. Бэкенд по ней
    // вычищает профиль через Deletion API: удаление аккаунта без этого
    // оставляет поведенческую историю человека в аналитике.
    String? analyticsId,
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    return ApiManager.instance.makeApiCall(
      callName: 'delete user NEW BCND',
      apiUrl: '${host}api/mirra/user/${userId}',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {
        if (analyticsId != null && analyticsId.isNotEmpty)
          'analytics_id': analyticsId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static int? remaining(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.remaining''',
      ));
  static bool? allowed(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.allowed''',
      ));
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}

// ── B3: NL phrase → facets ────────────────────────────────────────────────────

class ParseSearchPhraseCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? token = '',
    String? phrase = '',
    String? lang = 'en',
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;
    final body = json.encode({'phrase': phrase, 'lang': lang});
    return ApiManager.instance.makeApiCall(
      callName: 'parse search phrase',
      apiUrl: '${host}api/mirra/search/parse',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? facets(dynamic response) =>
      getJsonField(response, r'$.facets') as List?;
  static String? unparsed(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.unparsed'));
  static String? sort(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.sort'));
}

// ── B4: Faceted product search ────────────────────────────────────────────────

class SearchProductsCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? token = '',
    Map<String, List<String>>? facets,
    String? sort = 'fit',
    Map<String, dynamic>? profile,
    String? cursor,
    int? limit = 20,
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;
    final body = json.encode({
      'facets': facets ?? {},
      'sort': sort,
      'profile': profile ?? {},
      'cursor': cursor,
      'limit': limit,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'search products',
      apiUrl: '${host}api/mirra/search',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? results(dynamic response) =>
      getJsonField(response, r'$.results') as List?;
  static int? total(dynamic response) =>
      castToType<int>(getJsonField(response, r'$.total'));
  static String? cursor(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.cursor'));
  static bool? hasMore(dynamic response) =>
      castToType<bool>(getJsonField(response, r'$.has_more'));
  static String? narrowestFacet(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.narrowest_facet'));
}
