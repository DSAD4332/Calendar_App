import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'widgets.dart';

class CalendarMonthView extends StatelessWidget {
  final DateTime? selectedDate;
  final Map<DateTime, List<Event>> events;
  final Function(DateTime) onDaySelected;

  const CalendarMonthView({
    Key? key,
    required this.selectedDate,
    required this.events,
    required this.onDaySelected,
  }) : super(key: key);

  List<Event> _getEventsForDay(DateTime dateTime) {
    // Нормализация даты (обнуление времени)
    DateTime normalizedDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);
    return events[normalizedDate] ?? [];
  }

EventStatus getEventStatus(Event event) {
  final now = DateTime.now();
  if (event.startTime != null && event.endTime != null) {
    if (now.isBefore(event.startTime!)) {
      return EventStatus.upcoming; // Событие ещё не началось
    } else if (now.isAfter(event.endTime!)) {
      return EventStatus.completed; // Событие завершилось
    } else {
      return EventStatus.ongoing; // Событие идёт
    }
  }
  return EventStatus.upcoming; // Если времени нет, по умолчанию будущее
}

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Event>(
      firstDay: DateTime(2000),
      lastDay: DateTime(2050),
      focusedDay: selectedDate ?? DateTime.now(),
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      daysOfWeekHeight: 40.0,
      rowHeight: MediaQuery.of(context).size.height * 0.12,
      onDaySelected: (selectedDay, focusedDay) {
        onDaySelected(selectedDay);
      },
      eventLoader: _getEventsForDay,
      headerStyle: const HeaderStyle(
        titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 254, 254, 250), fontSize: 20.0),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 97, 64, 81),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Color.fromARGB(255, 254, 254, 250),
          size: 28,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Color.fromARGB(255, 254, 254, 250),
          size: 28,
        ),
        formatButtonVisible: false,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(color: Color.fromARGB(255, 102, 96, 96)),
      ),
      calendarStyle: CalendarStyle(
        weekendTextStyle:
            const TextStyle(color: Color.fromARGB(255, 102, 96, 96)),
        tableBorder: TableBorder.all(
          color: Colors.grey, // Цвет границ
          width: 1.0, // Толщина границ
        ),
      ),
      calendarBuilders: CalendarBuilders<Event>(
        defaultBuilder: (context, date, focusedDay) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${date.day}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
    markerBuilder: (context, date, events) {
      if (events.isNotEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: events.take(3).map((event) {
            final status = getEventStatus(event);

            // Определяем стиль для каждого состояния
            Color backgroundColor;
            IconData? icon;

            switch (status) {
              case EventStatus.upcoming:
                backgroundColor = Colors.green;
                icon = null;
                break;
              case EventStatus.ongoing:
                backgroundColor = Colors.orange;
                icon = Icons.access_time;
                break;
              case EventStatus.completed:
                backgroundColor = Colors.grey.withOpacity(0.3);
                icon = null;
                break;
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.eventTitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  if (icon != null)
                    Icon(
                      icon,
                      size: 12,
                      color: Colors.white,
                    ),
                ],
              ),
            );
          }).toList(),
        );
      }
      return const SizedBox.shrink();
    },
        todayBuilder: (context, date, focusedDay) {
          return Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 97, 64, 81),
              shape: BoxShape.rectangle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        selectedBuilder: (context, date, focusedDay) {
          return Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 59, 47, 47),
              shape: BoxShape.rectangle,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        outsideBuilder: (context, date, focusedDay) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${date.day}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
