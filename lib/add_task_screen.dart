import 'package:flutter/material.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  DateTime? _selectedDate;

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

  void _submit() {
    if (_controller.text.isEmpty) return;

    Navigator.pop(context, {
      "task": _controller.text,
      "desc": _descriptionController.text,
      "due": _selectedDate,
      "done": false,
    });
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _descriptionController.clear();
      _selectedDate = null;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              keyboardType: TextInputType.text,
              maxLength: 100,
              focusNode: _titleFocus,
              decoration: const InputDecoration(
                labelText: "Task Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: "Task Description",
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickDate,
                  child: _selectedDate == null
                      ? Icon(Icons.calendar_today)
                      : Row(
                          children: [
                            Text(
                              "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.edit),
                          ],
                        ),
                ),
              ],
            ),
            // SizedBox(
            //   child: TextButton(
            //     onPressed: _pickDate,
            //     child: _selectedDate == null
            //         ? ElevatedButton(child: Icon(Icons.calendar_today))
            //         : Text(
            //             "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
            //           ),
            //   ),
            // ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Add Task"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _reset,
                  child: Row(
                    children: [const Text("Reset"), const Icon(Icons.refresh)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
