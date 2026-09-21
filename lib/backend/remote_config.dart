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

    if (map.containsKey('free_scan_limit')) {
      final val = int.tryParse(map['free_scan_limit']!);
      if (val != null && val > 0) FFAppState().freeScanLimit = val;
    }
  } catch (e) {
    debugPrint('[RemoteConfig] ❌ fetch failed: $e');
  }
}
