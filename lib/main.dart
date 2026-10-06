import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/midpoint_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const DinePoint());
}

class DinePoint extends StatelessWidget {
  const DinePoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DinePoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1B1B2F), // Dark background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA8E6CF), // Teal/mint accent
          secondary: Color(0xFFFF6B6B), // Coral/red accent
          surface: Color(0xFF1B1B2F),
        ),
        fontFamily: 'Roboto',
      ),
      home: const InitialScreenLoader(),
    );
  }
}

class InitialScreenLoader extends StatelessWidget {
  const InitialScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return FutureBuilder<bool>(
      future: authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFA8E6CF),
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data == true) {
          return const MainNavigation();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const MidpointScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B2F),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1B1B2F),
          selectedItemColor: const Color(0xFFA8E6CF),
          unselectedItemColor: Colors.grey.shade600,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on), // You can use a better icon if you like
              label: 'Midpoint',
            ),
          ],
        ),
      ),
    );
  }
}