import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'services/app_state.dart';
import 'services/persistence_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (replace with your actual keys)
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://rssiaeynkwiamywqtpxe.supabase.co');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_n8AJrgxF_nnARX_5eLPAXA_2dW_ZneG');

  if (supabaseUrl != 'https://your-project.supabase.co') {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // Load persisted state
  final setupComplete = await PersistenceService.isSetupComplete();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: ICTorchApp(skipSetup: setupComplete),
    ),
  );
}

class ICTorchApp extends StatelessWidget {
  final bool skipSetup;
  const ICTorchApp({super.key, required this.skipSetup});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppState>().themeMode;
    final isIOS = Platform.isIOS;

    return MaterialApp(
      title: 'ICTorch',
      debugShowCheckedModeBanner: false,
      theme: appTheme(mode: mode, platform: isIOS ? TargetPlatform.iOS : TargetPlatform.android),
      home: skipSetup ? const HomeShell() : const SplashScreen(),
    );
  }
}
