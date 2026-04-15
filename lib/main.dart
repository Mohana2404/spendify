import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_expenses_screen.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    
        
        routes: {
          "/": (context) => const HomeScreen(),
          "/add-expense": (context) => const AddExpensesScreen(),
        },
        
    );  

    
  }
}

