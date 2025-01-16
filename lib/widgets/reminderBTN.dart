import 'package:flutter/material.dart';

class ReminderButton extends StatefulWidget {
  final Function(String) onReminderSelected;

  const ReminderButton({Key? key, required this.onReminderSelected})
      : super(key: key);

  @override
  _ReminderButtonState createState() => _ReminderButtonState();
}

class _ReminderButtonState extends State<ReminderButton> {
  String _selectedReminder = "None";

  void _showReminderDialog(BuildContext context) {
    TextEditingController customTimeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Reminder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("None"),
                value: "None",
                groupValue: _selectedReminder,
                onChanged: (value) {
                  setState(() {
                    _selectedReminder = value!;
                  });
                  widget.onReminderSelected("None");
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text("5 minutes before"),
                value: "5 minutes before",
                groupValue: _selectedReminder,
                onChanged: (value) {
                  setState(() {
                    _selectedReminder = value!;
                  });
                  widget.onReminderSelected("5 minutes before");
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text("Custom"),
                value: "Custom",
                groupValue: _selectedReminder,
                onChanged: (value) {
                  setState(() {
                    _selectedReminder = value!;
                  });
                },
              ),
              if (_selectedReminder == "Custom")
                TextField(
                  controller: customTimeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Custom time (minutes)",
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _selectedReminder = "$value minutes before";
                    });
                    widget.onReminderSelected(
                        "$value minutes before"); // Отправляем текст
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showReminderDialog(context),
      icon: const Icon(Icons.notifications),
      label: Text(_selectedReminder),
    );
  }
}
