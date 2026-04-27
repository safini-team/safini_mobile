import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:safini/core/app/app.dart';
import 'package:safini/core/config/supabase_bootstrap.dart';
import 'package:safini/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/env/app.env', isOptional: true);

  await configureDependencies();

  await initializeSupabaseIfConfigured();

  runApp(const MyApp());
}
