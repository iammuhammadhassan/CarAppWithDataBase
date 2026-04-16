import 'package:flutter/material.dart';
import '../models/car_details_screen.dart';
import '../models/car_model.dart';
import '../screens/showroom_screen.dart';

class AppRoutes {
  static const String showroom = '/';
  static const String carDetails = '/car-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case showroom:
        return MaterialPageRoute(
          builder: (_) => const ShowroomScreen(),
          settings: settings,
        );

      case carDetails:
        final args = settings.arguments;
        if (args is Car) {
          return MaterialPageRoute(
            builder: (_) => CarDetailsScreen(car: args),
            settings: settings,
          );
        }

        return MaterialPageRoute(
          builder: (_) => const _RouteErrorScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const _RouteErrorScreen(),
          settings: settings,
        );
    }
  }
}

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.showroom,
              (route) => false,
            );
          },
          child: const Text('Back to Showroom'),
        ),
      ),
    );
  }
}
