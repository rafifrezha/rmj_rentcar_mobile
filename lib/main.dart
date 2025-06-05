import 'package:flutter/material.dart';

// Import screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/main_screen.dart';
import 'screens/user/rental_screen.dart';
import 'screens/user/history_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/time_converter_screen.dart';
import 'screens/user/feedback_screen.dart';

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
        fontFamily: 'Poppins', // gunakan font Poppins di seluruh aplikasi
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Poppins'),
          displayMedium: TextStyle(fontFamily: 'Poppins'),
          displaySmall: TextStyle(fontFamily: 'Poppins'),
          headlineLarge: TextStyle(fontFamily: 'Poppins'),
          headlineMedium: TextStyle(fontFamily: 'Poppins'),
          headlineSmall: TextStyle(fontFamily: 'Poppins'),
          titleLarge: TextStyle(fontFamily: 'Poppins'),
          titleMedium: TextStyle(fontFamily: 'Poppins'),
          titleSmall: TextStyle(fontFamily: 'Poppins'),
          bodyLarge: TextStyle(fontFamily: 'Poppins', color: Color(0xFFE0E6ED)),
          bodyMedium: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFFE0E6ED),
          ),
          bodySmall: TextStyle(fontFamily: 'Poppins', color: Color(0xFFE0E6ED)),
          labelLarge: TextStyle(fontFamily: 'Poppins'),
          labelMedium: TextStyle(fontFamily: 'Poppins'),
          labelSmall: TextStyle(fontFamily: 'Poppins'),
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF00E09E), // #00e09e
          onPrimary: const Color(0xFF1A2236), // #1a2236
          secondary: const Color(0xFF232B3E), // #232b3e
          onSecondary: const Color(0xFFE0E6ED), // #e0e6ed
          error: Colors.red,
          onError: Colors.white,
          background: const Color(0xFF181F2F), // #181f2f
          onBackground: const Color(0xFFE0E6ED), // #e0e6ed
          surface: const Color(0xFF232B3E), // #232b3e
          onSurface: const Color(0xFFE0E6ED), // #e0e6ed
        ),
        scaffoldBackgroundColor: const Color(0xFF181F2F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A2236),
          foregroundColor: Color(0xFFE0E6ED),
          elevation: 0,
        ),
        cardColor: const Color(0xFF232B3E),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF232B3E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00E09E)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00E09E)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00E09E), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFFE0E6ED)),
          hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E09E),
            foregroundColor: const Color(0xFF1A2236),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF232B3E),
          labelStyle: const TextStyle(color: Color(0xFFE0E6ED)),
          selectedColor: const Color(0xFF00E09E),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScreen(),
        '/rental': (context) => const RentalScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/time-converter': (context) => const TimeConverterScreen(),
        '/feedback': (context) => const FeedbackScreen(),
      },
    );
  }
}
