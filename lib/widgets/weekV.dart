import 'package:flutter/material.dart';
import '../models/event.dart';
import 'header.dart';

class CalendarWeekView extends StatefulWidget {
  final DateTime selectedDate;
  final Map<DateTime, List<Event>> events;
  final Function(DateTime) onDaySelected;

  const CalendarWeekView({
    Key? key,
    required this.selectedDate,
    required this.events,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  State<CalendarWeekView> createState() => _CalendarWeekViewState();
}

class _CalendarWeekViewState extends State<CalendarWeekView> {
  late DateTime currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = widget.selectedDate;
  }

  void _goToPreviousWeek() {
    setState(() {
      currentDate = currentDate.subtract(const Duration(days: 7));
    });
    widget.onDaySelected(currentDate);
  }

  void _goToNextWeek() {
    setState(() {
      currentDate = currentDate.add(const Duration(days: 7));
    });
    widget.onDaySelected(currentDate);
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final int currentWeekday = date.weekday;
    final DateTime firstDayOfWeek =
        date.subtract(Duration(days: currentWeekday - 1));
    return List.generate(
        7, (index) => firstDayOfWeek.add(Duration(days: index)));
  }

  bool isSelectedDay(DateTime day) {
    return widget.selectedDate.year == day.year &&
        widget.selectedDate.month == day.month &&
        widget.selectedDate.day == day.day;
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> weekDays = _getWeekDays(currentDate);

    return Column(
      children: [
        // Заголовок
        CalendarHeader(
          title: "${weekDays.first.day}-${weekDays.last.day} ${[
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ][weekDays.first.month - 1]} ${currentDate.year}",
          onPrevious: _goToPreviousWeek,
          onNext: _goToNextWeek,
        ),

        // Верхняя панель с числами и днями недели
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays.map((day) {
            final bool isToday = day.year == DateTime.now().year &&
                day.month == DateTime.now().month &&
                day.day == DateTime.now().day;

            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onDaySelected(day),
                child: Container(
                  decoration: BoxDecoration(
                    border: isSelectedDay(day)
                        ? Border.all(
                            color: const Color.fromARGB(
                                255, 97, 64, 81), // Цвет обводки
                            width: 2.0, // Толщина обводки
                          )
                        : null, // Нет обводки для невыбранных дней
                    borderRadius: BorderRadius.circular(
                        8.0), // Радиус углов (опционально)
                  ),
                  padding: const EdgeInsets.all(
                      8.0), // Внутренние отступы для визуального эффекта
                  child: Column(
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? const Color.fromARGB(255, 97, 64, 81)
                              : Colors.black,
                        ),
                      ),
                      Text(
                        [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ][day.weekday - 1],
                        style: TextStyle(
                          fontSize: 14,
                          color: isToday
                              ? const Color.fromARGB(255, 97, 64, 81)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const Divider(),

        // Списки событий под днями недели
        Expanded(
          child: Row(
            children: weekDays.map((day) {
              final List<Event> dayEvents =
                  widget.events[DateTime(day.year, day.month, day.day)] ?? [];
              return Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: dayEvents.length,
                        itemBuilder: (context, index) {
                          final Event event = dayEvents[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 4.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              event.eventTitle,
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
