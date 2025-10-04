import 'package:flutter/material.dart';
import 'add_task_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const MyHomePage(title: 'todo app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> _items = [];

  void _navigateToAddTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    if (newTask != null) {
      setState(() {
        _items.add(newTask);
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "No due date selected";
    return "${date.day}/${date.month}/${date.year}";
  }

  void _toggleDone(int index) {
    setState(() {
      _items[index]["done"] = !_items[index]["done"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todo App")),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: _items[index]["done"]
                ? const Icon(Icons.check_circle_rounded)
                : const Icon(Icons.check_circle_outlined),
            title: Text(
              _items[index]["task"],
              style: TextStyle(
                fontSize: 18,
                decoration: _items[index]["done"]
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            onTap: () => _toggleDone(index),
            subtitle: Text("Due: ${_formatDate(_items[index]["due"])}"),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
