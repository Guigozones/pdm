import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'navigation/routes.dart';

void main() {
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
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routeMap,
      onUnknownRoute: AppRoutes.unknownRoute,
    );
  }
}
