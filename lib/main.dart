import 'package:flutter/material.dart';
import 'add_task_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('todos');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        // pageTransitionsTheme: const PageTransitionsTheme(builders: {Tar}),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
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
  final Box _box = Hive.box('todos');

  void _navigateToAddTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    if (newTask != null) {
      _box.add(newTask);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "No due date selected";
    return "${date.day}/${date.month}/${date.year}";
  }

  void _toggleDone(int index) {
    var item = _box.getAt(index) as Map;
    _box.putAt(index, {
      "task": item["task"],
      "done": !item["done"],
      "due": item["due"],
    });
  }

  void _deleteTask(int index) {
    _box.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo App"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No tasks yet"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final item = box.getAt(index) as Map;
              return ListTile(
                leading: item["done"]
                    ? const Icon(Icons.check_circle_rounded)
                    : const Icon(Icons.check_circle_outlined),
                title: Text(
                  item["task"],
                  style: TextStyle(
                    fontSize: 18,
                    decoration: item["done"]
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                trailing: Tooltip(
                  message: "Delete this task!",
                  child: ElevatedButton(
                    onPressed: () => _deleteTask(index),
                    child: Icon(Icons.delete, color: Colors.red),
                  ),
                ),

                onTap: () => _toggleDone(index),
                subtitle: Text("Due: ${_formatDate(item["due"])}"),
              );
            },
          );
        },
      ),

      floatingActionButton: Tooltip(
        message: "Add a new task",
        child: FloatingActionButton(
          onPressed: _navigateToAddTask,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
