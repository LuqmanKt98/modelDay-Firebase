import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:new_flutter/pages/landing_page.dart';
import 'package:new_flutter/services/auth_service.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:new_flutter/utils/simple_route_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🚀 APP STARTING - main() called');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firestore after Firebase - let it use default settings for web
  debugPrint('✅ Firebase and Firestore initialized successfully');

  debugPrint('🏃 Running MyApp...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ MyApp.build() called');
    return ChangeNotifierProvider(
      create: (context) => AuthService.instance,
      child: _buildMaterialApp(context),
    );
  }

  Widget _buildMaterialApp(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return MaterialApp(
          title: 'Model Day',
          debugShowCheckedModeBanner: false, // Remove debug banner
          navigatorKey: navigatorKey,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.dark(
              primary: AppTheme.goldColor,
              secondary: AppTheme.goldColor,
              surface: Colors.grey[900]!,
            ),
            textTheme: ThemeData.dark().textTheme,
            scaffoldBackgroundColor: Colors.black,
          ),
          initialRoute: '/',
          onGenerateRoute: (settings) {
            debugPrint('🧭 onGenerateRoute called for: ${settings.name}');

            final routeName = settings.name ?? '/';

            final page = SimpleRouteManager.getPageForRoute(
              routeName,
              isAuthenticated: authService.isAuthenticated,
              isInitialized: authService.isInitialized,
            );

            return MaterialPageRoute(
              builder: (context) => page,
              settings: settings,
            );
          },
          onUnknownRoute: (settings) {
            debugPrint('🚨 Unknown route accessed: ${settings.name}');
            return MaterialPageRoute(
              builder: (context) => const LandingPage(),
            );
          },
        );
      },
    );
  }


}
