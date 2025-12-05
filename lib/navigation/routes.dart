import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/recover_screen.dart';
import '../screens/home_screen.dart';
import '../screens/document_verification_screen.dart';
import '../screens/vehicles_screen.dart';
import '../screens/routes_screen.dart';
import '../screens/relatorios_screen.dart';

/// Definição de todas as rotas da aplicação
/// Centraliza a navegação em um único lugar para facilitar manutenção
class AppRoutes {
  // Rotas da aplicação
  static const String login = '/';
  static const String register = '/register';
  static const String recover = '/recover';
  static const String documentVerification = '/document-verification';
  static const String home = '/home';
  static const String vehicles = '/vehicles';
  static const String routes = '/routes';
  static const String relatorios = '/relatorios';

  /// Mapa de rotas para MaterialApp
  static final Map<String, WidgetBuilder> routeMap = {
    AppRoutes.login: (_) => const LoginScreen(),
    AppRoutes.register: (_) => RegisterScreen(),
    AppRoutes.recover: (_) => RecoverScreen(),
    AppRoutes.documentVerification: (_) => const DocumentVerificationScreen(),
    AppRoutes.home: (_) => HomeScreen(),
    AppRoutes.vehicles: (_) => VehiclesScreen(),
    AppRoutes.routes: (_) => const RoutesScreen(),
    AppRoutes.relatorios: (_) => const RelatoriosScreen(),
  };

  /// Handler para rotas desconhecidas
  static Route<dynamic> unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Rota não encontrada')),
        body: Center(
          child: Text('Rota "${settings.name}" não encontrada.'),
        ),
      ),
    );
  }
}
