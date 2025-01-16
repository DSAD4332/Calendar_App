import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveEvent(DateTime date, Event event) async {
    try {
      String dateKey = _dateToKey(date);

      await _firestore.collection('events').doc(dateKey).set({
        'events': FieldValue.arrayUnion([event.toJson()])
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving event: $e');
      rethrow;
    }
  }

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<Map<DateTime, List<Event>>> fetchEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').get();

      Map<DateTime, List<Event>> events = {};
      for (var doc in snapshot.docs) {
        String dateKey = doc.id;
        DateTime date = DateTime.parse(dateKey);

        List<dynamic> eventsData = doc['events'] ?? [];
        events[date] = eventsData.map((e) => Event.fromJson(e)).toList();
      }
      return events;
    } catch (e) {
      print('Error fetching events: $e');
      return {};
    }
  }

  Future<void> deleteEvent(Event event) async {
    try {
      String dateKey = _dateToKey(event.startTime!);

      DocumentSnapshot doc =
          await _firestore.collection('events').doc(dateKey).get();

      if (doc.exists) {
        List<dynamic> events = doc['events'] ?? [];
        events.removeWhere((e) => Event.fromJson(e).isEqualTo(event));

        if (events.isEmpty) {
          await _firestore.collection('events').doc(dateKey).delete();
        } else {
          await _firestore.collection('events').doc(dateKey).update({
            'events': events,
          });
        }

        print('Event deleted: ${event.eventTitle}');
      } else {
        print('No events found for date: $dateKey');
      }
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  Future<void> updateEvent(Event oldEvent, Event newEvent) async {
    try {
      String oldDateKey = _dateToKey(oldEvent.startTime!);
      String newDateKey = _dateToKey(newEvent.startTime!);

      DocumentSnapshot oldDoc =
          await _firestore.collection('events').doc(oldDateKey).get();

      if (oldDoc.exists) {
        List<dynamic> oldEvents = oldDoc['events'] ?? [];

        oldEvents.removeWhere((e) => Event.fromJson(e).isEqualTo(oldEvent));

        if (oldEvents.isEmpty) {
          await _firestore.collection('events').doc(oldDateKey).delete();
        } else {
          await _firestore.collection('events').doc(oldDateKey).update({
            'events': oldEvents,
          });
        }
      }

      DocumentSnapshot newDoc =
          await _firestore.collection('events').doc(newDateKey).get();

      if (newDoc.exists) {
        List<dynamic> newEvents = newDoc['events'] ?? [];
        newEvents.add(newEvent.toJson());

        await _firestore.collection('events').doc(newDateKey).update({
          'events': newEvents,
        });
      } else {
        await _firestore.collection('events').doc(newDateKey).set({
          'events': [newEvent.toJson()],
        });
      }

      print(
          'Event updated from: ${oldEvent.eventTitle} to: ${newEvent.eventTitle}');
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

}
