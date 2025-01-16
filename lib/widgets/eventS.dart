import '../models/event.dart';

enum EventStatus { upcoming, ongoing, completed }

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
  return EventStatus.upcoming; // По умолчанию, если времени нет
}
