import 'package:riverpod/riverpod.dart';
import 'services/supabase_service.dart';

final supabaseServiceProvider = Provider((ref) => SupabaseService());
