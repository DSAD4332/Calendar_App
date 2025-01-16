import 'package:flutter/material.dart';

class RepeatButton extends StatefulWidget {
  final Function(String) onRepeatSelected;

  const RepeatButton({Key? key, required this.onRepeatSelected})
      : super(key: key);

  @override
  _RepeatButtonState createState() => _RepeatButtonState();
}

class _RepeatButtonState extends State<RepeatButton> {
  String _selectedRepeat = "Does not repeat";

  void _showRepeatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: const Text("Does not repeat"),
              onTap: () {
                setState(() {
                  _selectedRepeat = "Does not repeat";
                });
                widget.onRepeatSelected(_selectedRepeat);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("Daily"),
              onTap: () {
                setState(() {
                  _selectedRepeat = "Daily";
                });
                widget.onRepeatSelected(_selectedRepeat);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("Weekly"),
              onTap: () {
                setState(() {
                  _selectedRepeat = "Weekly";
                });
                widget.onRepeatSelected(_selectedRepeat);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("Monthly"),
              onTap: () {
                setState(() {
                  _selectedRepeat = "Monthly";
                });
                widget.onRepeatSelected(_selectedRepeat);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text("Yearly"),
              onTap: () {
                setState(() {
                  _selectedRepeat = "Yearly";
                });
                widget.onRepeatSelected(_selectedRepeat);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showRepeatOptions(context),
      icon: const Icon(Icons.repeat),
      label: Text(_selectedRepeat),
    );
  }
}
