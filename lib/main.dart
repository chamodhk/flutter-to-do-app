import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_task_screen.dart';
import 'view_task_screen.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  void _navigateToShowTask(int index) async {
    var task = Map<String, dynamic>.from(_box.getAt(index));
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewTaskScreen(task: task)),
    );

    if (newTask != null) {
      _box.putAt(index, newTask);
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
      "desc": item["desc"],
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
        title: _isSearching
            ? Container(
                height: kToolbarHeight,
                alignment: Alignment.center,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    hintText: 'Search tasks..',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              )
            : const Text("Todo App"),

        backgroundColor: Colors.blueAccent,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _box.listenable(),
              builder: (context, box, _) {
                final allTasks = box.values
                    .cast<Map>()
                    .toList()
                    .where((task) => task["done"] == false)
                    .toList();

                final filteredTasks = _searchQuery.isEmpty
                    ? allTasks
                    : allTasks
                          .where(
                            (task) =>
                                task['task'].toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                task['desc'].toLowerCase().contains(
                                  _searchQuery,
                                ),
                          )
                          .toList();

                return SlidableAutoCloseBehavior(
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final item = filteredTasks[index];
                      return Slidable(
                        key: Key(item["task"] + index.toString()),

                        startActionPane: ActionPane(
                          extentRatio: 0.3,
                          motion: DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                _toggleDone(index);
                              },
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              icon: Icons.done_all_rounded,
                              label: "Mark as completed",
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          extentRatio: 0.2,
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
                                : const Icon(Icons.pending_actions_outlined),
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
                            ),

                            // trailing: Tooltip(
                            //   message: "Delete this task!",
                            //   child: ElevatedButton(
                            //     onPressed: () => _deleteTask(index),
                            //     child: Icon(Icons.delete, color: Colors.red),
                            //   ),
                            // ),
                            onTap: () => _navigateToShowTask(index),
                            subtitle: Text("Due: ${_formatDate(item["due"])}"),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Tooltip(
        message: "Add a new task",
        child: FloatingActionButton(
          backgroundColor: Colors.lightBlueAccent,
          onPressed: () => _openAddTaskSheet(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
