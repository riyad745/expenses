import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ExpanseApp());
}

class ExpanseApp extends StatelessWidget {
  const ExpanseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ExpenseListScreen(),
    );
  }
}

class Expense {
  final String date;
  final String title;
  final String description;
  final String price;

  Expense({
    required this.date,
    required this.title,
    required this.description,
    required this.price,
  });
}

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> expenses = [];
  late DateTime selectedDate; // Declare selectedDate variable

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // Initialize selectedDate
    _loadExpenses();
  }

  void _loadExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? expenseStrings = prefs.getStringList('expenses');
    if (expenseStrings != null) {
      setState(() {
        expenses = expenseStrings.map((e) {
          var split = e.split(',');
          return Expense(
            date: split[0],
            title: split[1],
            description: split[2],
            price: split[3],
          );
        }).toList();
      });
    }
  }

  void _saveExpense(Expense expense) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    expenses.add(expense);
    List<String> expenseStrings = expenses
        .map((e) => '${e.date},${e.title},${e.description},${e.price}')
        .toList();
    prefs.setStringList('expenses', expenseStrings);
    setState(() {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Added Succesfully')));
    });
  }

  void _deleteExpense(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    expenses.removeAt(index);
    List<String> expenseStrings = expenses
        .map((e) => '${e.date},${e.title},${e.description},${e.price}')
        .toList();
    prefs.setStringList('expenses', expenseStrings);
    setState(() {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Deleted Successfully')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Expense List'),
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${expenses[index].date}'),
                  Text('Title: ${expenses[index].title}'),
                  const SizedBox(height: 8),
                  const Text('Description:'),
                  Text(expenses[index].description),
                  const SizedBox(height: 8),
                  Text('Price: \$${expenses[index].price}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _deleteExpense(index);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addExpense(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addExpense(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController titleController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();
        TextEditingController priceController = TextEditingController();

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Add Expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text(
                      'Date:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != selectedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                      ),
                    ),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Enter title',
                    ),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Enter description',
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      hintText: 'Enter price',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    Expense newExpense = Expense(
                      date:
                          '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                      title: titleController.text,
                      description: descriptionController.text,
                      price: priceController.text,
                    );
                    _saveExpense(newExpense);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
