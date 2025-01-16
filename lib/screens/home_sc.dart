import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/widgets.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  final GoogleSignInAccount user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  late DateTime selectedCalendarDate;
  late Map<DateTime, List<Event>> mySelectedEvents;
  bool _isExpanded = false;
  late FlutterLocalNotificationsPlugin localNotifications;
  CalendarFormatType currentCalendarFormat = CalendarFormatType.month;

  late TextEditingController titleController;
  late TextEditingController descpController;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isAllDay = false;
  String selectedReminder = "None";
  String selectedRepeat = "Does not repeat";

  @override
  void initState() {
    selectedCalendarDate = DateTime.now();
    mySelectedEvents = {};
    super.initState();

    startTime = TimeOfDay.now();
    endTime = TimeOfDay.now();
    titleController = TextEditingController();
    descpController = TextEditingController();

    // Настройка уведомлений
    localNotifications = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    localNotifications.initialize(initSettings);

    _loadEventsFromDatabase();
  }

  @override
  void dispose() {
    titleController.dispose();
    descpController.dispose();
    super.dispose();
  }

  void _loadEventsFromDatabase() async {
    final databaseService = DatabaseService();
    Map<DateTime, List<Event>> events = await databaseService.fetchEvents();

    setState(() {
      mySelectedEvents = events;
    });
  }

// Метод для отображения текущего формата календаря
  Widget _buildCalendarView() {
    switch (currentCalendarFormat) {
      case CalendarFormatType.day:
        return CalendarDayView(
          selectedDate: selectedCalendarDate,
          events: mySelectedEvents,
          onDaySelected: (selectedDay) {
            if (selectedCalendarDate == selectedDay) {
              _showAddEventModal(context);
            } else {
              setState(() {
                selectedCalendarDate = selectedDay;
              });
            }
          },
        );
      case CalendarFormatType.week:
        return CalendarWeekView(
          selectedDate: selectedCalendarDate,
          events: mySelectedEvents,
          onDaySelected: (selectedDay) {
            if (selectedCalendarDate == selectedDay) {
              _showAddEventModal(context);
            } else {
              setState(() {
                selectedCalendarDate = selectedDay;
              });
            }
          },
        );
      case CalendarFormatType.month:
        return CalendarMonthView(
          selectedDate: selectedCalendarDate,
          events: mySelectedEvents,
          onDaySelected: (selectedDay) {
            if (selectedCalendarDate == selectedDay) {
              _showAddEventModal(context);
            } else {
              setState(() {
                selectedCalendarDate = selectedDay;
              });
            }
          },
        );
    }
  }

// Переключение формата календаря
  void _toggleCalendarFormat() {
    setState(() {
      switch (currentCalendarFormat) {
        case CalendarFormatType.day:
          currentCalendarFormat = CalendarFormatType.week;
          break;
        case CalendarFormatType.week:
          currentCalendarFormat = CalendarFormatType.month;
          break;
        case CalendarFormatType.month:
          currentCalendarFormat = CalendarFormatType.day;
          break;
      }
    });
  }

  void scheduleReminder(Event event) {
    if (event.startTime == null || event.reminderTime == null) return;

    final reminderTime = event.startTime!.subtract(event.reminderTime!);

    localNotifications.zonedSchedule(
      event.hashCode,
      'Reminder: ${event.eventTitle}',
      event.eventDescp,
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Event reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  List<Event> _listOfDayEvents(DateTime dateTime) {
    DateTime normalizedDate = normalizeDate(dateTime);
    return mySelectedEvents[normalizedDate] ?? [];
  }

  Future<List<Event>> generateRepeatedEvents(
      Event event, DateTime startDate, DateTime endDate) async {
    List<Event> repeatedEvents = [];
    DateTime? currentDate = event.startTime;

    while (currentDate != null && currentDate.isBefore(endDate)) {
      repeatedEvents.add(Event(
        eventTitle: event.eventTitle,
        eventDescp: event.eventDescp,
        startTime: currentDate,
        endTime: event.endTime != null
            ? currentDate.add(Duration(
                hours: event.endTime!.hour - event.startTime!.hour,
                minutes: event.endTime!.minute - event.startTime!.minute,
              ))
            : null,
        isAllDay: event.isAllDay,
        reminder: event.reminder,
        repeat: event.repeat,
      ));

      switch (event.repeat) {
        case "Daily":
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case "Weekly":
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case "Monthly":
          currentDate = DateTime(
              currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        case "Yearly":
          currentDate = DateTime(
              currentDate.year + 1, currentDate.month, currentDate.day);
          break;
        default:
          currentDate = null; // Завершаем цикл, если повторение не указано
      }
    }
    return repeatedEvents;
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _addEvent(DateTime date, Event event) async {
    final databaseService = DatabaseService();

    // Выполним асинхронную работу до вызова setState
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);

    if (event.isAllDay) {
      event.startTime = DateTime(date.year, date.month, date.day, 0, 0);
      event.endTime = DateTime(date.year, date.month, date.day, 23, 59);
    }

    if (event.repeat != "Does not repeat") {
      DateTime endDate = DateTime.now().add(const Duration(days: 365));

      // Ожидаем завершения генерации повторяющихся событий
      List<Event> repeatedEvents =
          await generateRepeatedEvents(event, normalizedDate, endDate);

      // Используем setState только после завершения асинхронной работы
      setState(() {
        for (var repeated in repeatedEvents) {
          DateTime normalizedEventDate = normalizeDate(repeated.startTime!);

          mySelectedEvents[normalizedEventDate] ??= [];
          mySelectedEvents[normalizedEventDate]!.add(repeated);
          databaseService.saveEvent(repeated.startTime!, repeated);
          // Запланировать напоминание
          if (repeated.reminder != "None") {
            scheduleReminder(repeated);
          }
        }
      });
    } else {
      // Если событие не повторяется, добавляем его непосредственно
      setState(() {
        mySelectedEvents[normalizedDate] ??= [];
        mySelectedEvents[normalizedDate]!.add(event);

        // Запланировать напоминание
        if (event.reminder != "None") {
          scheduleReminder(event);
        }
      });

      // Сохранение события в базу данных
      await databaseService.saveEvent(date, event);
    }
  }

  Future<void> _editEvent(Event oldEvent, Event updatedEvent) async {
    // Создаем копию oldEvent, чтобы избежать его изменения
    Event oldEventClone = Event(
      eventTitle: oldEvent.eventTitle,
      eventDescp: oldEvent.eventDescp,
      startTime: oldEvent.startTime,
      endTime: oldEvent.endTime,
      isAllDay: oldEvent.isAllDay,
      reminder: oldEvent.reminder,
      repeat: oldEvent.repeat,
      reminderTime: oldEvent.reminderTime,
    );

    setState(() {
      if (oldEventClone.startTime == null || updatedEvent.startTime == null) {
        print('Error: Event startTime is null.');
        return;
      }

      DateTime oldDate = normalizeDate(oldEventClone.startTime!);
      DateTime newDate = normalizeDate(updatedEvent.startTime!);

      // Удаляем старое событие
      if (mySelectedEvents.containsKey(oldDate)) {
        bool removed =
            mySelectedEvents[oldDate]?.remove(oldEventClone) ?? false;

        if (!removed) {
          print('Warning: Old event not found in the list.');
        }
        if (mySelectedEvents[oldDate]?.isEmpty ?? false) {
          mySelectedEvents.remove(oldDate);
        }
      }

      // Добавляем обновленное событие
      mySelectedEvents[newDate] ??= [];
      mySelectedEvents[newDate]!.add(updatedEvent);
    });

    // Обновление события в базе данных
    final databaseService = DatabaseService();
    await databaseService.updateEvent(oldEventClone, updatedEvent);
  }

  Future<void> _deleteEvent(Event event) async {
    setState(() {
      DateTime normalizedDate = normalizeDate(event.startTime!);

      mySelectedEvents[normalizedDate]?.remove(event);
      if (mySelectedEvents[normalizedDate]?.isEmpty ?? false) {
        mySelectedEvents.remove(normalizedDate);
      }
    });

    // Удаление события из базы данных
    final databaseService = DatabaseService();
    await databaseService.deleteEvent(event);
  }

  void _showAddEventModal(BuildContext context, {Event? event}) {
    if (event != null) {
      // Заполнение контроллеров данными события
      titleController.text = event.eventTitle;
      descpController.text = event.eventDescp;
      startTime = TimeOfDay.fromDateTime(event.startTime ?? DateTime.now());
      endTime = TimeOfDay.fromDateTime(event.endTime ?? DateTime.now());
      isAllDay = event.isAllDay;
      selectedReminder = event.reminder;
      selectedRepeat = event.repeat;
    } else {
      // Очистка контроллеров для нового события
      titleController.text = '';
      descpController.text = '';
      startTime = TimeOfDay.now();
      endTime = TimeOfDay.now();
      isAllDay = false;
      selectedReminder = "None";
      selectedRepeat = "Does not repeat";
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 5 / 6,
          maxChildSize: 5 / 6,
          builder: (_, scrollController) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: _buildAddEventForm(context, event: event),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child:
                    _buildCalendarView(), // Метод для отображения текущего формата
              ),
            ],
          ),
          // IconButton поверх заголовка календаря
          Positioned(
            top: MediaQuery.of(context).size.height *
                0.01, // Отступ от верхней границы
            left: MediaQuery.of(context).size.width * 0.6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.view_list),
                  color: Colors.white,
                  onPressed: () {
                    _toggleCalendarFormat();
                  },
                ),
                AccountButton(user: widget.user),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? 350 : 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      height: 40,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: Icon(
                        _isExpanded ? Icons.expand_more : Icons.expand_less,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children:
                          _listOfDayEvents(selectedCalendarDate).map((myEvent) {
                        return ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(myEvent.eventTitle),
                          subtitle: Text(myEvent.eventDescp),
                          onTap: () {
                            _showAddEventModal(context, event: myEvent);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEventForm(BuildContext context, {Event? event}) {
    final isEditMode = event != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок и поле для названия события на одном уровне
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEditMode ? 'Edit Event' : 'Add Event',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Event Title'),
                  onSubmitted: (value) {
                    // Просто завершить ввод текста, без очистки
                    FocusScope.of(context).unfocus(); // Закрыть клавиатуру
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descpController.text.isNotEmpty) {
                  final newEvent = Event(
                    eventTitle: titleController.text,
                    eventDescp: descpController.text,
                    startTime: isAllDay
                        ? null
                        : DateTime(
                            selectedCalendarDate.year,
                            selectedCalendarDate.month,
                            selectedCalendarDate.day,
                            startTime?.hour ?? 0,
                            startTime?.minute ?? 0,
                          ),
                    endTime: isAllDay
                        ? null
                        : DateTime(
                            selectedCalendarDate.year,
                            selectedCalendarDate.month,
                            selectedCalendarDate.day,
                            endTime?.hour ?? 0,
                            endTime?.minute ?? 0,
                          ),
                    isAllDay: isAllDay,
                    reminder: selectedReminder,
                    repeat: selectedRepeat,
                  );

                  if (isEditMode) {
                    _editEvent(event, newEvent);
                  } else {
                    _addEvent(selectedCalendarDate, newEvent);
                  }
                  titleController.clear();
                  descpController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Icon(isEditMode ? Icons.save : Icons.add), // Только иконка
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Поле описания занимает всю ширину
        TextField(
          controller: descpController,
          maxLines: null,
          decoration: const InputDecoration(
            labelText: 'Event Description',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            FocusScope.of(context).unfocus(); // Закрыть клавиатуру
          },
        ),
        const SizedBox(height: 20),

        // Селектор времени события
        EventTimeSelector(
          initialStartTime: startTime,
          initialEndTime: endTime,
          initialAllDay: isAllDay,
          onTimeChanged: (start, end, allDay) {
            setState(() {
              startTime = start;
              endTime = end;
              isAllDay = allDay;
            });
          },
        ),
        const SizedBox(height: 20),

        // Кнопки Reminder и Repeat расположены столбиком
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReminderButton(
              onReminderSelected: (reminder) {
                setState(() {
                  selectedReminder = reminder;
                });
              },
            ),
            const SizedBox(height: 10),
            RepeatButton(
              onRepeatSelected: (repeat) {
                setState(() {
                  selectedRepeat = repeat;
                });
              },
            ),
          ],
        ),
        const Spacer(),

        // Кнопка удаления и сохранения
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Кнопка удаления в режиме редактирования
            if (isEditMode)
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    _deleteEvent(event);
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    size: 30,
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
