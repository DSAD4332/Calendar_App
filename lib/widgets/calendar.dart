import 'package:flutter/material.dart';
import 'widgets.dart';

class CalendarView extends StatelessWidget {
  final DateTime selectedDate;
  final Map<DateTime, List<Event>> events;
  final Function(DateTime) onDaySelected;
  final CalendarFormatType currentFormat;

  const CalendarView({
    Key? key,
    required this.selectedDate,
    required this.events,
    required this.onDaySelected,
    required this.currentFormat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (currentFormat) {
      case CalendarFormatType.day:
        return CalendarDayView(
          selectedDate: selectedDate,
          events: events,
          onDaySelected: onDaySelected,
        );
      case CalendarFormatType.week:
        return CalendarWeekView(
          selectedDate: selectedDate,
          events: events,
          onDaySelected: onDaySelected,
        );
      case CalendarFormatType.month:
        return CalendarMonthView(
          selectedDate: selectedDate,
          events: events,
          onDaySelected: onDaySelected,
        );
    }
  }
}
