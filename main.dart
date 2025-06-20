import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'models/worker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Worker? _loggedInWorker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final workerId = prefs.getInt('worker_id');
    final fullName = prefs.getString('full_name');
    final email = prefs.getString('email');
    final phone = prefs.getString('phone');
    final address = prefs.getString('address');

    if (workerId != null && fullName != null && email != null) {
      setState(() {
        _loggedInWorker = Worker(
          id: workerId,
          fullName: fullName,
          email: email,
          phone: phone,
          address: address,
        );
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onLoginSuccess(Worker worker) {
    setState(() {
      _loggedInWorker = worker;
    });
  }

  void _onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _loggedInWorker = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Worker Task Management',
      theme: ThemeData(
        // Define a primary color for consistent branding
        primaryColor: const Color(0xFF42A5F5), // A pleasant blue
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: const Color(0xFF66BB6A)), // A pleasant green for secondary actions

        // Text Theme for improved readability
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: Colors.black87),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.black87),
          displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
          bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
          labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white),
        ),

        // AppBar Theme - now a solid color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF42A5F5), // Solid primary color
          foregroundColor: Colors.white,
          elevation: 4, // Retain subtle shadow
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white), // Ensure back button and action icons are white
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF66BB6A), // Secondary color for FAB
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),

        // Elevated Button Theme for consistent button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42A5F5), // Primary color for buttons
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Slightly more rounded buttons
            ),
            elevation: 5, // Subtle shadow for buttons
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Input Decoration Theme for text fields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded input fields
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.blueGrey[50], // Light grey background for input fields
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: TextStyle(color: Theme.of(context).primaryColor),
          prefixIconColor: Theme.of(context).primaryColor,
        ),

        // Card Theme for consistent card styling
        cardTheme: CardTheme(
          elevation: 6, // Slightly more pronounced shadow for cards
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded card corners
          ),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          elevation: 8,
          type: BottomNavigationBarType.fixed, // Ensures all labels are shown
        ),

        // Add a general background color for Scaffold
        scaffoldBackgroundColor: Colors.blueGrey[50], // A very light blue-grey background
      ),
      home: _loggedInWorker == null
          ? LoginScreen(onLoginSuccess: _onLoginSuccess)
          : HomeScreen(worker: _loggedInWorker!, onLogout: _onLogout),
      debugShowCheckedModeBanner: false,
    );
  }
}