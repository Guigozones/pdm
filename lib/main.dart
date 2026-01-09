import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'navigation/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase com tratamento de erro
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase já inicializado, continua normalmente
  }
  
  runApp(const VansApp());
}

class VansApp extends StatelessWidget {
  const VansApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Box Leste - Vans',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Localizações para DatePicker e outros widgets
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('pt', 'BR'),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routeMap,
      onUnknownRoute: AppRoutes.unknownRoute,
    );
  }
}
