import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class OpenAIImageGenerationAPICall {
  static Future<ApiCallResponse> call({
    String? prompt = '',
    String? style = '',
    String? size = '1024x1024',
  }) async {
    final ffApiRequestBody = '''
{
  "model": "dall-e-3",
  "prompt": "${prompt}. In the style of ${style}.",
  "n": 1,
  "size": "${size}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'OpenAI Image Generation API',
      apiUrl: 'https://api.openai.com/v1/images/generations',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer OPENAI_API_KEY',
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

  static dynamic revisedPrompt(dynamic response) => getJsonField(
        response,
        r'''$.data[:].revised_prompt''',
      );
  static dynamic tempURL(dynamic response) => getJsonField(
        response,
        r'''$.data[:].url''',
      );
}

class TelegrammessegeCall {
  static Future<ApiCallResponse> call({
    String? messega = 'null',
    String? email = 'null',
    String? form = 'null',
  }) async {
    final ffApiRequestBody = '''
{
  "chat_id": 170963862,
  "text": "У нас новое сообщение из приложения beaty box! Пользователь с почтой: ${escapeStringForJson(email)}. Форма: ${escapeStringForJson(form)}. Сообщение: ${escapeStringForJson(messega)}",
  "parse_mode": "HTML"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Telegrammessege',
      apiUrl:
          'https://api.telegram.org/bot7386187800:AAFmXbepKWdBlBCFmbyoalIge6Gh_AapPbw/sendMessage',
      callType: ApiCallType.POST,
      headers: {},
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

class OpenAIFineTunedModelCall {
  static Future<ApiCallResponse> call({
    String? yourOpenaiApiKey =
        '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',
    String? label = 'null',
    String? parametr = 'null',
  }) async {
    final ffApiRequestBody = '''
{
  "model": "ft:gpt-4.1-2025-04-14:localize-app::BPsYjUR8",
  "messages": [
    {
      "role": "system",
      "content": "You are an assistant that answers only with the requested property of a cosmetic product. Reply with the value of the property and nothing else."
    },
    {
      "role": "user",
      "content": "Product: Label: ${escapeStringForJson(label)}\\nReturn only: ${escapeStringForJson(parametr)}"
    }
  ],
  "temperature": 0
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'OpenAIFineTunedModel',
      apiUrl: 'https://api.openai.com/v1/chat/completions',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${yourOpenaiApiKey}',
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

  static String? content(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.choices[:].message.content''',
      ));
}

class OpenAIComponenAnalysCall {
  static Future<ApiCallResponse> call({
    String? yourOpenaiApiKey =
        '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',
    String? productIngeridients = 'null',
  }) async {
    final ffApiRequestBody = '''
{
  "model": "gpt-4o",
  "temperature": 0.2,
  "messages": [
    {
      "role": "system",
      "content": "You are a professional evaluator of cosmetic product formulations.\\n\\nYou analyze skincare products based on their full INCI (International Nomenclature of Cosmetic Ingredients) list. Your evaluation must be strict, medically accurate, evidence-based, and relevant for users with acne-prone, sensitive, oily, dry, or combination skin. Focus only on ingredients that have a real impact on skin health. Avoid marketing language or vague claims.\\n\\nApply the following evaluation logic:\\n\\n---\\n\\n1. 🔬 Functional Categorization: For each ingredient, classify its role:\\n- Humectants (e.g. glycerin, hyaluronic acid)\\n- Emollients (e.g. squalane, jojoba oil)\\n- Occlusives (e.g. dimethicone, petrolatum)\\n- Barrier-repairing (e.g. ceramides, cholesterol, fatty acids)\\n- Antioxidants (e.g. tocopherol, green tea, ferulic acid)\\n- Exfoliants (AHA/BHA/PHA)\\n- Actives (e.g. niacinamide, panthenol, retinol, centella asiatica)\\n- Preservatives (e.g. phenoxyethanol, sodium benzoate)\\n- Fragrances (e.g. parfum, essential oils)\\n- Irritants (e.g. alcohol denat., BHT, PEGs, linalool)\\n- Comedogenic ingredients (e.g. coconut oil, isopropyl myristate)\\n\\n2. 📊 Position-Sensitive Evaluation:\\n- Top 5 ingredients = high concentration = strong impact\\n- Positions #6–10 = medium impact\\n- After #10 = low or negligible impact\\n- Strongly penalize irritants and comedogenics in the top 5\\n\\n3. 🚫 Strictly Forbidden:\\n- If Cyclohexasiloxane is present → apply a -3.0 penalty and issue a clear warning\\n\\n4. 🛢 Oils in High Concentration:\\n- If coconut oil, shea butter, or similar oils are in the top 5 → warn about greasy feel or comedogenicity, especially for oily or acne-prone skin. Apply a penalty based on oil type.\\n\\n5. 🧴 BB or CC Creams:\\n- If product name includes \\"BB Cream\\" or \\"CC Cream\\" → recommend double cleansing and warn that SPF protection may be unreliable\\n\\n6. 🧠 Synergy & Conflict:\\n- Warn about problematic combinations (e.g. retinol + AHA, vitamin C + niacinamide in sensitive skin)\\n- Reward synergistic combos (e.g. ceramides + cholesterol + fatty acids)\\n\\n7. 📈 Scoring System:\\n- Base Score = 5.0\\n- +0.3 for each beneficial active in top 10\\n- +0.2 for good humectants or barrier-repair agents\\n- -0.5 for each irritant or comedogen in top 5\\n- -0.2 if found in position 6–10\\n- -1.0 for strictly forbidden ingredients (e.g. Cyclohexasiloxane)\\n- -0.3 for risky combinations\\n- Round to one decimal, cap between 0.0 and 10.0\\n\\n8. 🧾 Output Format:\\n\\nX.X / 10\\n\\n✅ Pros:\\n• Ingredient (position #X): +reason  \\n• Ingredient (position #Y): +reason\\n\\n❌ Cons:\\n• Ingredient (position #X): -reason  \\n• Ingredient (position #Y): -reason\\n\\n⚠️ Warnings:\\n• Specific ingredient-based risks or interactions\\n\\n📌 Final note:\\nBrief professional summary of product performance, safety, and skin-type recommendations.\\n\\n9. 🔽 Rating Line for Parsing:\\nAt the very end of your message, add a separate line in the format:\\nRating: X.X  \\n(e.g. Rating: 8.2)\\n\\nThis line must be the last one. Do not include it in the analysis text. It is meant for backend parsing and storage only.\\n\\n---\\n\\nBe strict, concise, and expert. Do not explain what INCI means. Use clinical tone, not friendly or promotional language."
    },
    {
      "role": "user",
      "content": "${escapeStringForJson(productIngeridients)}"
    }
  ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'OpenAIComponenAnalys',
      apiUrl: 'https://api.openai.com/v1/chat/completions',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${yourOpenaiApiKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? analysresult(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.choices[:].message.content''',
      ));
}

class OpenAINameProductFromImageCall {
  static Future<ApiCallResponse> call({
    String? yourOpenaiApiKey =
        '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',
    String? url = '',
  }) async {
    final ffApiRequestBody = '''
{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "user",
      "content": [
        { "type": "text", "text": "Based on an image of a cosmetic product, identify the main product and return only its full commercial name. Do not include any explanations or additional information." },
        { "type": "image_url", "image_url": { "url": "${escapeStringForJson(url)}" } }
      ]
    }
  ]
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'OpenAINameProductFromImage',
      apiUrl: 'https://api.openai.com/v1/chat/completions',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${yourOpenaiApiKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: true,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? analysresult(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.choices[:].message.content''',
      ));
}

class OpenAIFineTunedModelWebSearchCall {
  static Future<ApiCallResponse> call({
    String? yourOpenaiApiKey =
        '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',
    String? productName = 'null',
  }) async {
    final ffApiRequestBody = '''
{
  "model": "gpt-4.1",
  "tools": [
    {
      "type": "web_search_preview"
    }
  ],
  "input": "You are a specialized AI whose only function is to retrieve the exact, complete, and accurate INCI ingredient list for cosmetic products. Return ONLY the full and exact list of ingredients separated clearly by commas. Do NOT add explanations, additional text, or URLs for this product named: ${escapeStringForJson(productName)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'OpenAIFineTunedModelWebSearch',
      apiUrl: 'https://api.openai.com/v1/responses',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${yourOpenaiApiKey}',
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

  static String? ingridientsoutput(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.output[1].content[0].text''',
      ));
}

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

class LocalizecampgetproductparameterCall {
  static Future<ApiCallResponse> call({
    String? parameter = '',
    String? label = '',
  }) async {
    final ffApiRequestBody = '''
{
    "parameter": "${escapeStringForJson(parameter)}",
    "label": "${escapeStringForJson(label)}"  }''';
    return ApiManager.instance.makeApiCall(
      callName: 'localizecampgetproductparameter',
      apiUrl: 'https://api.localizecamp.com/get-product-parameter',
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

  static String? value(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.value''',
      ));
}

class LocalizecampextractproductnamefromimageCall {
  static Future<ApiCallResponse> call({
    String? imageUrl = '',
  }) async {
    final ffApiRequestBody = '''
{
    "image_url": "${escapeStringForJson(imageUrl)}" }''';
    return ApiManager.instance.makeApiCall(
      callName: 'localizecampextractproductnamefromimage',
      apiUrl: 'https://api.localizecamp.com/extract-product-name-from-image',
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

  static String? productname(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.product_name''',
      ));
}

class LocalizecampgetincilistCall {
  static Future<ApiCallResponse> call({
    String? productName = '',
  }) async {
    final ffApiRequestBody = '''
{
    "product_name": "${escapeStringForJson(productName)}" }''';
    return ApiManager.instance.makeApiCall(
      callName: 'localizecampgetincilist',
      apiUrl: 'https://api.localizecamp.com/get-inci-list',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer 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',
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

  static String? incilist(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.inci_list''',
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
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "image_id": "${escapeStringForJson(imageId)}",
  "product_name": "${escapeStringForJson(productName)}",
  "brand": "${escapeStringForJson(brand)}",
  "country": "${escapeStringForJson(country)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'searchingredients NEW BCND',
      apiUrl: '${host}api/mirra/search-ingredients',
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

class ScientificanalysisNEWBCNDCall {
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
  "language_code": "${escapeStringForJson(languageCode)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'scientificanalysis NEW BCND',
      apiUrl: '${host}api/mirra/scientific-analysis',
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

class FeedbackNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    String? imageId = '',
    String? userId = '',
    bool? vote,
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
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    final ffApiRequestBody = '''
{
  "image_url": "${escapeStringForJson(imageUrl)}",
  "user_id": "${escapeStringForJson(userId)}",
  "language_code": "${escapeStringForJson(languageCode)}",
  "country": "${escapeStringForJson(country)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'extractproductinfo NEW BCND Copy',
      apiUrl: '${host}api/mirra/extract-product-info',
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
}

class CopyproductNEWBCNDCall {
  static Future<ApiCallResponse> call({
    String? host,
    int? sourceImageId,
    String? targetUserId = '',
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
  }) async {
    host ??= FFDevEnvironmentValues().backendhost;

    return ApiManager.instance.makeApiCall(
      callName: 'delete user NEW BCND',
      apiUrl: '${host}api/mirra/user/${userId}',
      callType: ApiCallType.DELETE,
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
