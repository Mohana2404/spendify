import 'package:flutter/material.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: HomeScreen(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddExpense()));
          },
          child: Icon(Icons.add),
        ),
      ),    

    );
  }
}

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

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _titleController= TextEditingController();
  final _amountController= TextEditingController();
  DateTime? _selectedDate;
  final _formKey= GlobalKey<FormState>();
  void datePicker() async{
    final selectedDate= await showDatePicker(
      context: context, 
      firstDate: DateTime(1999), 
      lastDate: DateTime.now(),
      initialDate: DateTime.now());

   
  
   if(selectedDate != null){
      setState(() {
          _selectedDate = selectedDate;
      });
    }
     print(selectedDate);
  }

  void submitForm(){
    final enteredTitle= _titleController.text;
    final enteredAmount= double.parse(_amountController.text);
    
    print("Title: $enteredTitle, Amount: $enteredAmount, Date: $_selectedDate");
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body:
      Form(
        key: _formKey,
        child: 
          Column(
           
            children: [
          TextFormField(
            controller: _titleController,
            validator: (value) => value == null || value.isEmpty ? "Please enter a title" : null,
            decoration: InputDecoration(
              
              labelText: "Expense Title",
              border: OutlineInputBorder()
              ,
              ),
            keyboardType: TextInputType.text,
          ),
          TextFormField(
            controller: _amountController,
            validator: (value) => value == null || value.isEmpty ? "Please enter an amount" : null,
            decoration: InputDecoration(
              labelText: "Amount",
              border: OutlineInputBorder(),
              ),
            keyboardType: TextInputType.number,
          ),
          Text(_selectedDate == null ? "No Date Chosen!" : "Picked Date: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}"),
          
           TextButton(onPressed: () => datePicker(), child: Text("select date")),
            ElevatedButton(onPressed: () =>submitForm() , child: Text("Add Expense"))
            ]
          )
      ),
    );    
  }
}