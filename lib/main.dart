import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:safini/core/app/app.dart';
import 'package:safini/core/config/supabase_bootstrap.dart';
import 'package:safini/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/env/app.env', isOptional: true);

  // Reads google-services.json / GoogleService-Info.plist, so there is no
  // generated options file to keep in sync. A build without them still runs,
  // just without protection alerts.
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (error) {
    debugPrint('Firebase unavailable, push alerts are off: $error');
  }

  await configureDependencies(firebaseReady: firebaseReady);

  await initializeSupabaseIfConfigured();

  runApp(const MyApp());
}
