import 'package:flutter/material.dart';
import '../models/event.dart';
import 'header.dart';

class CalendarDayView extends StatefulWidget {
  final DateTime selectedDate;
  final Map<DateTime, List<Event>> events;
  final Function(DateTime) onDaySelected;

  const CalendarDayView({
    Key? key,
    required this.selectedDate,
    required this.events,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  State<CalendarDayView> createState() => _CalendarDayViewState();
}

class _CalendarDayViewState extends State<CalendarDayView> {
  late PageController _pageController;
  late DateTime baseDate;

  @override
  void initState() {
    super.initState();
    baseDate = widget.selectedDate;
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Получить события для конкретной даты
  List<Event> _getEventsForDay(DateTime dateTime) {
    DateTime normalizedDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);
    return widget.events[normalizedDate] ?? [];
  }

  /// Переход к предыдущему дню
  void _goToPreviousDay() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Переход к следующему дню
  void _goToNextDay() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Построить представление дня
  Widget _buildDayView(DateTime? date) {
    if (date == null) {
      return const Center(
        child: Text(
          'Invalid date',
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
    }

    final events = _getEventsForDay(date);

    return SingleChildScrollView(
      child: Column(
        children: [
          CalendarHeader(
            title: "${date.day} ${[
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
            ][date.month - 1]} ${date.year}",
            onPrevious: _goToPreviousDay,
            onNext: _goToNextDay,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                color: Colors.grey.shade200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getWeekdayName(date),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${date.day}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: events.isEmpty
                    ? Center(
                        child: Text(
                          'No events for ${date.day} ${_getWeekdayName(date)}',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 8.0),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              '${event.eventTitle} (${event.eventDescp})',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (pageIndex) {
                setState(() {
                  final offsetDays = pageIndex;
                  final newDate = baseDate.add(Duration(days: offsetDays));
                  widget.onDaySelected(newDate);
                });
              },
              itemBuilder: (context, pageIndex) {
                final day = baseDate.add(Duration(days: pageIndex));
                return _buildDayView(day);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Возвращает название дня недели
  String _getWeekdayName(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[date.weekday - 1];
  }
}
