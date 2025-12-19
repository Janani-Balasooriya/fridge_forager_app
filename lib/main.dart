import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

// FIREBASE IMPORTS
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

// MODEL IMPORTS
import 'features/inventory/data/models/ingredient_model.dart';
import 'features/shopping_list/data/models/shopping_item_model.dart';
import 'features/dashboard/presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // LOAD .ENV
  try {
    await dotenv.load(fileName: ".env"); 
  } catch (e) {
    print("Warning: .env file not found.");
  }

  // INITIALIZE FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // INITIALIZE HIVE
  await Hive.initFlutter();

  // --- SAFE ADAPTER REGISTRATION ---
  
// Ingredient Unit (ID 0)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(IngredientUnitAdapter());
  }

  // Ingredient (ID 1)
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(IngredientAdapter());
  }

  // Shopping Item (ID 2)
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ShoppingItemAdapter());
  }

  runApp(const ProviderScope(child: FridgeForagerApp()));
}

class FridgeForagerApp extends ConsumerWidget {
  const FridgeForagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FridgeForager',
      debugShowCheckedModeBanner: false,
      
      // THEME DATA
      theme: ThemeData(
        useMaterial3: true,
        
        // Color Palette
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2ECC71), // Emerald Green
          secondary: const Color(0xFFFF9F1C), // Tangerine
          surface: Colors.white,              
          background: const Color(0xFFF8F9FA),
          error: const Color(0xFFFF6B6B),
          brightness: Brightness.light,
        ),

        // Background
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),

        // App Bar
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF2D3436),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF2D3436)),
        ),

        // Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        // Input Fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFF2ECC71).withOpacity(0.2),
          labelStyle: const TextStyle(color: Colors.black87),
          secondaryLabelStyle: const TextStyle(color: Color(0xFF27AE60)),
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.transparent),
          ),
        ),
      ),
      
      home: const MainScreen(),
    );
  }
}