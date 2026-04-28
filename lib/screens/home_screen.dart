import "package:flutter/material.dart";
import "package:http/http.dart";
import 'dart:convert';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spendify")),
      body: const 
         Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CategoryCard()
          ],
        ),
        
        
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/add-expense");
        },
        child: const Icon(Icons.add),
        
      ),
       
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
    );
    
  }
}

            

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(30.0),
        elevation: 5,
        child: 
        Padding(padding: EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [ 
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Food"),
                Text(totalExpenses.toStringAsFixed(2)),


                
              ],
            ),
            Container(
              child: Text(
                "Food",
                style: TextStyle(fontSize: 16),
              ),
              decoration: BoxDecoration(
                
                borderRadius: BorderRadius.circular(5),
                
              ),
              padding: EdgeInsets.all(8),
            ),
          ],
        )

        ),
      );
      
 }
}

Future<String> _fetchExpenses() async {
  final url = Uri.parse('https://127.0.0.1:8000/expenses');
  final response = await get(url);
  response.statusCode == 200
      ? print('Expenses fetched successfully: ${response.body}')
      : print('Failed to fetch expenses. Status code: ${response.statusCode}');
      
  return response.body;


}

var expensesData = _fetchExpenses();
var totalExpenses = 0.0;
void calculateTotalExpenses(String expensesJson) {
  totalExpenses = (jsonDecode(expensesJson) as List).fold(0.0, (sum, expense) => sum + expense['amount']);  
}


