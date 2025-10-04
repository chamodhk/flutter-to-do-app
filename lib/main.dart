import 'package:flutter/material.dart';

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
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _items = [];
  DateTime? _selectedDate;

  void _handleSubmit() {
    if (_controller.text.isEmpty) return;

    setState(() {
      _items.add({
        "task": _controller.text,
        "done": false,
        'due': _selectedDate,
      });
      _controller.clear();
      _selectedDate = null;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "No due date selected";
    return "${date.day}/${date.month}/${date.year}";
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: "Enter something",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _handleSubmit(),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(_formatDate(_selectedDate)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _handleSubmit, child: const Text("Submit")),
          Expanded(
            child: ListView.builder(
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
          ),
        ],
      ),
    );
  }
}
