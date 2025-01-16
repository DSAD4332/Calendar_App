class Event {
  String eventTitle;
  String eventDescp;
  DateTime? startTime;
  DateTime? endTime;
  bool isAllDay;
  String reminder; // "None", "5 minutes before", "Custom"
  String repeat;
  Duration? reminderTime; // Добавленное поле

  Event({
    required this.eventTitle,
    required this.eventDescp,
    this.startTime,
    this.endTime,
    required this.isAllDay,
    required this.reminder,
    required this.repeat,
    this.reminderTime,
  });
  // Конвертация в JSON для Firestore
  Map<String, dynamic> toJson() {
    return {
      'eventTitle': eventTitle,
      'eventDescp': eventDescp,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isAllDay': isAllDay,
      'reminder': reminder,
      'repeat': repeat,
      'reminderTime': reminderTime?.inSeconds,
    };
  }

  // Создание объекта из JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventTitle: json['eventTitle'] as String,
      eventDescp: json['eventDescp'] as String,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null,
      isAllDay: json['isAllDay'] as bool,
      reminder: json['reminder'] as String,
      repeat: json['repeat'] as String,
      reminderTime: json['reminderTime'] != null
          ? Duration(seconds: json['reminderTime'] as int)
          : null,
    );
  }
  // Метод для сравнения двух событий
  bool isEqualTo(Event other) {
    return eventTitle == other.eventTitle &&
        eventDescp == other.eventDescp &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        isAllDay == other.isAllDay &&
        reminder == other.reminder &&
        repeat == other.repeat;
  }

  @override
  String toString() {
    return 'Event: $eventTitle, '
        'Description: $eventDescp, '
        'Start: ${startTime?.toString() ?? "All day"}, '
        'End: ${endTime?.toString() ?? "All day"}, '
        'Reminder: $reminder, '
        'Repeat: $repeat';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Event &&
        other.eventTitle == eventTitle &&
        other.eventDescp == eventDescp &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isAllDay == isAllDay &&
        other.reminder == reminder &&
        other.repeat == repeat &&
        other.reminderTime == reminderTime;
  }

  @override
  int get hashCode {
    return eventTitle.hashCode ^
        eventDescp.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        isAllDay.hashCode ^
        reminder.hashCode ^
        repeat.hashCode ^
        reminderTime.hashCode;
  }
}
