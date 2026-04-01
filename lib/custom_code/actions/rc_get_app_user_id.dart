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

//
// rc_get_app_user_id.dart
import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<String> rcGetAppUserId(BuildContext context) async {
  // Вернёт текущего активного пользователя в RevenueCat.
  // Если вы не логинились — это будет RCAnonymousID:...
  final appUserId = await Purchases.appUserID;
  return appUserId;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
