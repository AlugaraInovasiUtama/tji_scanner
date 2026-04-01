import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/scanner/presentation/product_info_screen.dart';
import '../../features/scanner/presentation/location_info_screen.dart';
import '../../features/scanner/presentation/pallet_info_screen.dart';
import '../../features/scanner/data/scan_service.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'di/injection.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(const SplashScreen(), settings);
      case '/login':
        return _buildRoute(const LoginScreen(), settings);
      case '/dashboard':
        return _buildRoute(const DashboardScreen(), settings);
      case '/product-info':
        return _buildRoute(
          ProductInfoScreen(scanService: sl<ScanService>()),
          settings,
        );
      case '/location-info':
        return _buildRoute(
          LocationInfoScreen(scanService: sl<ScanService>()),
          settings,
        );
      case '/pallet-info':
        return _buildRoute(
          PalletInfoScreen(scanService: sl<ScanService>()),
          settings,
        );
      case '/settings':
        return _buildRoute(const SettingsScreen(), settings);
      default:
        return _buildRoute(
          const Scaffold(body: Center(child: Text('Route not found'))),
          settings,
        );
    }
  }

  static PageRouteBuilder<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
