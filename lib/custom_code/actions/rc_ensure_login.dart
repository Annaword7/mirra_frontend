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
import 'package:purchases_flutter/purchases_flutter.dart';

Future<String> rcEnsureLogin(BuildContext context, String appUserId) async {
  // Skip login when no valid user ID (e.g. paywall shown before account creation)
  if (appUserId.isEmpty) {
    return await Purchases.appUserID;
  }
  try {
    final current = await Purchases.appUserID;
    if (current != appUserId) {
      await Purchases.logIn(appUserId);
    }
  } catch (e) {
    debugPrint('rcEnsureLogin error: $e');
    // Don't rethrow — a login failure shouldn't block the purchase UI
  }
  return await Purchases.appUserID;
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
