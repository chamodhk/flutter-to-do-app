import 'package:flutter/material.dart';

class ViewTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  const ViewTaskScreen({super.key, required this.task});

  @override
  State<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  bool _isEditing = false;
  late bool _done = widget.task["done"];
  String _formatDate(DateTime? date) {
    if (date == null) return "No due date selected";
    return "${date.day}/${date.month}/${date.year}";
  }

  late TextEditingController _titleController = TextEditingController(
    text: widget.task["task"],
  );

  late TextEditingController _descriptionController = TextEditingController(
    text: widget.task["desc"],
  );

  late TextEditingController _dateController = TextEditingController(
    text: _formatDate(widget.task["due"]),
  );

  late DateTime? _datePicked = widget.task["due"];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task["task"]);
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _datePicked ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    setState(() {
      _datePicked = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  void _toggleDone() {
    setState(() {
      _done = !_done;
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _onSave() {
    Navigator.pop(context, {
      "task": _titleController.text,
      "desc": _descriptionController.text,
      "due": _datePicked,
      "done": _done,
    });
  }

  Future<bool> _onWillPop() async {
    _onSave();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("View or edit"),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // (ElevatedButton(
                    //   onPressed: _isEditing ? null : () => _toggleEdit(),
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.edit),
                    //       SizedBox(width: 5),
                    //       const Text("Edit Task"),
                    //     ],
                    //   ),
                    // )),
                    (SizedBox(width: 10)),
                    (ElevatedButton(
                      onPressed: _toggleEdit,
                      child: _isEditing
                          ? Row(
                              children: [
                                Icon(Icons.save),
                                SizedBox(width: 5),
                                Text("Save"),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 5),
                                Text("Edit Task"),
                              ],
                            ),
                    )),
                    Spacer(),

                    ElevatedButton(
                      onPressed: _toggleDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _done ? Colors.green : Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        children: [
                          _done
                              ? const Text("Completed")
                              : const Text("Pending"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),
              TextField(
                controller: _titleController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                maxLength: 100,
                readOnly: !_isEditing,
                decoration: InputDecoration(
                  labelText: "Task Title",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              TextField(
                controller: _descriptionController,
                readOnly: !_isEditing,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: "Task Description",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Due Date",
                  border: OutlineInputBorder(),
                ),
                onTap: _isEditing ? () => _pickDate() : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
