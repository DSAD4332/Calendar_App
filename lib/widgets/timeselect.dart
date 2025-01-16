import 'package:flutter/material.dart';

class EventTimeSelector extends StatefulWidget {
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final bool initialAllDay;
  final void Function(TimeOfDay startTime, TimeOfDay endTime, bool allDay)
      onTimeChanged;

  const EventTimeSelector({
    Key? key,
    this.initialStartTime,
    this.initialEndTime,
    this.initialAllDay = false,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  _EventTimeSelectorState createState() => _EventTimeSelectorState();
}

class _EventTimeSelectorState extends State<EventTimeSelector> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStartTime ?? TimeOfDay.now();
    _endTime = widget.initialEndTime ?? TimeOfDay.now();
    _isAllDay = widget.initialAllDay;
  }

  Future<TimeOfDay?> _selectTime(BuildContext context, TimeOfDay initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
  }

  void _handleTimeChange() {
    widget.onTimeChanged(_startTime, _endTime, _isAllDay);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton(
              onPressed: _isAllDay
                  ? null
                  : () async {
                      final pickedTime = await _selectTime(context, _startTime);
                      if (pickedTime != null) {
                        setState(() {
                          _startTime = pickedTime;
                        });
                        _handleTimeChange();
                      }
                    },
              child: Text('Start: ${_startTime.format(context)}'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _isAllDay
                  ? null
                  : () async {
                      final pickedTime = await _selectTime(context, _endTime);
                      if (pickedTime != null) {
                        setState(() {
                          _endTime = pickedTime;
                        });
                        _handleTimeChange();
                      }
                    },
              child: Text('End: ${_endTime.format(context)}'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: _isAllDay,
              onChanged: (value) {
                setState(() {
                  _isAllDay = value!;
                });
                _handleTimeChange();
              },
            ),
            const Text('All Day'),
          ],
        ),
      ],
    );
  }
}
