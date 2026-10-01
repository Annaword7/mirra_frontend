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

import 'package:flutter/services.dart';

Future lockOrientation() async {
  // На iOS ориентации раздаёт AppDelegate: iPhone — портрет, iPad — все
  // четыре (iPadOS 26 перестала уважать блокировку и требует поворота).
  // Вызов отсюда пересилил бы его и запер бы iPad в портрете.
  if (isiOS) return;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
