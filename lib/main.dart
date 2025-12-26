import 'package:flutter/material.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text("Spendify")),
        body: Card(
        margin: EdgeInsets.all(8.0),
        elevation: 5,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [ 
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Groceries "),
                Text("26-dec"),
                
              ],
            ),
            Container(
              child: Text("-500.00 ₹"),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(5),
                
              ),
              padding: EdgeInsets.all(8),
            ),
          ],
        )
        
        
      ));    }
} 