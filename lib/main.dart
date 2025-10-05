import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_task_screen.dart';

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

  // void _navigateToAddTask() async {
  //   final newTask = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const AddTaskScreen()),
  //   );

  //   if (newTask != null) {
  //     _box.add(newTask);
  //   }
  // }

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

  void _openAddTaskSheet(BuildContext context) async {
    final newTask = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddTaskScreen(),
    );

    if (newTask != null) {
      _box.add(newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text("Todo App"),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No tasks yet"));
          }

          return SlidableAutoCloseBehavior(
            child: ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final item = box.getAt(index) as Map;
                return Slidable(
                  key: Key(item["task"] + index.toString()),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          _deleteTask(index);
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Container(
                    height: 80,
                    // margin: const EdgeInsets.symmetric(
                    //   vertical: 6,
                    //   horizontal: 4,
                    // ),
                    child: ListTile(
                      leading: item["done"]
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            )
                          : const Icon(Icons.check_circle_outlined),
                      title: Text(
                        item["task"],
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: item["done"]
                              ? FontWeight.normal
                              : FontWeight.bold,

                          decoration: item["done"]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        // TextStyle(
                        //   fontFamily: "sans-serif",
                        //   fontSize: 18,
                        //   decoration: item["done"]
                        //       ? TextDecoration.lineThrough
                        //       : TextDecoration.none,
                        //   fontWeight: item["done"]
                        //       ? FontWeight.normal
                        //       : FontWeight.bold,
                        // ),
                      ),

                      // trailing: Tooltip(
                      //   message: "Delete this task!",
                      //   child: ElevatedButton(
                      //     onPressed: () => _deleteTask(index),
                      //     child: Icon(Icons.delete, color: Colors.red),
                      //   ),
                      // ),
                      onTap: () => _toggleDone(index),
                      subtitle: Text("Due: ${_formatDate(item["due"])}"),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: Tooltip(
        message: "Add a new task",
        child: FloatingActionButton(
          onPressed: () => _openAddTaskSheet(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
