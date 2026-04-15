import "package:flutter/material.dart";
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text("Spendify")),
        body: 
        Column ( 
          children: [
            ExpenseCard(title: "Groceries", date: "26-dec", amount: "-500.00 ₹"),
            ExpenseCard(title: "Electricity Bill", date: "27-dec", amount: "-1200.00 ₹"),
            ExpenseCard(title: "Dinner Out", date: "28-dec", amount: "-800.00 ₹"),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/add-expense");
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            )
          ],
        )
        
      );
    }
}

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.title, required this.date, required this.amount});
  final String title;
  final String date;
  final String amount;
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
                Text(title),
                Text(date),
                
              ],
            ),
            Container(
              child: Text(
                amount.toString()),
              decoration: BoxDecoration(
                color: Colors.red[100],
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

