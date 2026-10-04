import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseConfig {
  static const url = 'https://aggiedvngedbhzjrkkrw.supabase.co';
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static Future<void> initialize() async {
    if (url.isEmpty || publishableKey.isEmpty) {
      throw StateError(
        'Missing Supabase configuration. Run with SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY dart defines.',
      );
    }

    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }
}
