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

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<dynamic> rcPurchasePackage(
  BuildContext context,
  String offeringId,
  String packageId,
  String appUserId,
) async {
  try {
    // Логиним пользователя
    final current = await Purchases.appUserID;
    if (current != appUserId) {
      await Purchases.logIn(appUserId);
    }

    // Получаем офферинг и пакет
    final offerings = await Purchases.getOfferings();
    final offering = offerings.all[offeringId];
    if (offering == null) {
      throw Exception('Offering "$offeringId" not found.');
    }

    final pkg = offering.availablePackages.firstWhere(
      (p) => p.identifier == packageId,
      orElse: () => throw Exception(
        'Package "$packageId" not found in "$offeringId". '
        'Available: ${offering.availablePackages.map((p) => p.identifier).toList()}',
      ),
    );

    // Совершаем покупку — теперь возвращается PurchaseResult
    final purchaseResult = await Purchases.purchasePackage(pkg);
    final customerInfo = purchaseResult.customerInfo;

    return {
      'ok': true,
      'appUserId': appUserId,
      'activeEntitlements': customerInfo.entitlements.active.keys.toList(),
    };
  } on PlatformException catch (e) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    final isCancelled = code == PurchasesErrorCode.purchaseCancelledError;
    return {
      'ok': false,
      'cancelled': isCancelled,
      'code': code.toString(),
      'message': e.message ?? e.toString(),
    };
  } catch (e) {
    return {
      'ok': false,
      'cancelled': false,
      'code': 'unknown',
      'message': e.toString(),
    };
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
