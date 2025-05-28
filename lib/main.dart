import 'package:flutter/material.dart';

// Import screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/main_screen.dart';
import 'screens/user/rental_screen.dart';
import 'screens/user/history_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/admin/manage_cars_screen.dart';
import 'screens/admin/manage_rentals_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RMJ RentCar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
        '/rental': (context) => const RentalScreen(),
        '/history': (context) => const HistoryScreen(),
        '/admin': (context) => const AdminScreen(),
        '/admin/manage-cars': (context) => const ManageCarsScreen(),
        '/admin/manage-rentals': (context) => const ManageRentalsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/splash': (context) => const SplashScreen(),
      },
    );
  }
}
