import 'package:flutter/foundation.dart';
import '/app_state.dart';
import '/backend/supabase/supabase.dart';

/// Fetches feature flags from the `app_config` Supabase table and writes them
/// to FFAppState. Safe to call before the user is authenticated (anon read).
Future<void> fetchRemoteConfig() async {
  try {
    final rows = await SupaFlow.client
        .from('app_config')
        .select('key, value');

    final map = <String, String>{
      for (final row in rows) row['key'] as String: row['value'] as String,
    };

    if (map.containsKey('feedbackCollectorEnabled')) {
      final val = map['feedbackCollectorEnabled']!.toLowerCase() == 'true';
      debugPrint('[RemoteConfig] feedbackCollectorEnabled=$val (raw="${map['feedbackCollectorEnabled']}") ');
      FFAppState().feedbackCollectorEnabled = val;
    } else {
      debugPrint('[RemoteConfig] feedbackCollectorEnabled key not found in app_config');
    }
  } catch (e) {
    debugPrint('[RemoteConfig] ❌ fetch failed: $e');
  }
}
