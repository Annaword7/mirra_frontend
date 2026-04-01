// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// rc_is_entitlement_active.dart
import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<bool> rcIsEntitlementActive(
  BuildContext context,
  String entitlementId,
  String? appUserId,
  bool loginIfUserId,
) async {
  // Если передан appUserId и разрешён логин — логиним пользователя в RC.
  if (loginIfUserId == true && appUserId != null && appUserId.isNotEmpty) {
    try {
      await Purchases.logIn(appUserId);
    } catch (e) {
      // Если логин не удался, продолжим как есть (под анонимом),
      // но можно залогировать ошибку в Crashlytics/Sentry.
      debugPrint('RevenueCat logIn error: $e');
    }
  }

  // Получаем актуальную информацию о пользователе и проверяем entitlement.
  try {
    final customerInfo = await Purchases.getCustomerInfo();
    final isActive =
        customerInfo.entitlements.active.containsKey(entitlementId);
    return isActive;
  } catch (e) {
    debugPrint('RevenueCat getCustomerInfo error: $e');
    return false;
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
