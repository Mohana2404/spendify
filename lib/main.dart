import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/create_group_screen.dart';
import 'screens/add_expenses_screen.dart';
import 'screens/group_details_screen.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Arial',
      ),
      routes: {
        "/": (context) => const HomeScreen(),
        "/add-expense": (context) => const AddExpensesScreen(),
        "/create-group": (context) => const CreateGroupScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/group-details') {
          // Pass the group as an argument
          final args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) {
              return GroupDetailsScreen(group: args); // Wait, I need to pass the Group
            },
          );
        }
        return null;
      },
    );
  }
}
