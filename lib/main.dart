import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'pages/transaction_page.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const EUFApp());
}

class EUFApp extends StatelessWidget {
  const EUFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'EUF Portal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Lato',
          primarySwatch: Colors.blueGrey,
          brightness: Brightness.dark, // Dark theme as per screenshots
          scaffoldBackgroundColor: const Color(0xFF1A1C2C), // Dark background
          cardColor: const Color(0xFF2C2F40), // Darker card background
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
            titleLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            titleMedium: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(color: Colors.white54),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // Button color
              foregroundColor: Colors.white, // Text color
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            print(
              'Main Consumer - isLoading: ${authProvider.isLoading}, isAuthenticated: ${authProvider.isAuthenticated}',
            );

            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (authProvider.isAuthenticated) {
              // Return your main app page here
              print('Navigating to TransactionPage');
              return const TransactionPage(); // Replace with your main dashboard page
            }

            print('Navigating to LoginPage');
            return const LoginPage();
          },
        ),
      ),
    );
  }
}

// Define a breakpoint for mobile/desktop layout
const double kMobileBreakpoint = 800.0;
