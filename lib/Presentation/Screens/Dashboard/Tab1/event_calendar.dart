import 'package:btech/Presentation/styles/elevated_button_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'individualEvent.dart';
 // Make sure to import your event detail screen here

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, Map<String, dynamic>> _dateToEventMap = {};
  Map<String, dynamic>? _selectedEvent;

  bool _isDateHighlighted(DateTime day) {
    return _dateToEventMap.keys.any((d) => isSameDay(d, day));
  }

  Map<String, dynamic>? _getEventForDay(DateTime day) {
    for (var entry in _dateToEventMap.entries) {
      if (isSameDay(entry.key, day)) {
        return entry.value;
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetch_all_events() async {
    CollectionReference organizerRef = FirebaseFirestore.instance.collection('Organizers');
    QuerySnapshot organizerSnap = await organizerRef.get();
    List<Map<String, dynamic>> eventsList = [];

    for (var organizers in organizerSnap.docs) {
      CollectionReference eventRef = organizers.reference.collection('Events');
      QuerySnapshot eventSnap = await eventRef.get();

      for (var events in eventSnap.docs) {
        Map<String, dynamic> eventData = events.data() as Map<String, dynamic>;
        eventData['organizer_id'] = organizers['id'];
        eventsList.add(eventData);
      }
    }

    return eventsList;
  }

  void loadEventsIntoCalendar() async {
    List<Map<String, dynamic>> events = await fetch_all_events();
    setState(() {
      print(events);
      for (var event in events) {
        DateTime date = DateTime.parse(event['start_date']);
        _dateToEventMap[date] = event;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadEventsIntoCalendar();
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvent = _getEventForDay(selectedDay);
              });
              print("Here is selected event");
              print(_selectedEvent);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (_isDateHighlighted(day)) {
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text('${day.day}', style: TextStyle(color: Colors.white)),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          _selectedEvent != null
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4,
              color: Colors.purple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedEvent!['name'] ?? '',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedEvent!['description'] ?? '',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: elevated_button_style(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Individualevent(
                              name: _selectedEvent!['name'] ?? '',
                              date: _selectedEvent!['start_date'] ?? '',
                              organizer: _selectedEvent!['department'] ?? '',
                              eventInfo: _selectedEvent!['type'] ?? '',
                              startTime: _selectedEvent!['start_time'] ?? '',
                              endTime: _selectedEvent!['end_time'] ?? '',
                              venue: _selectedEvent!['venue'] ?? '',
                              description: _selectedEvent!['description'] ?? '',
                              min_team_size: _selectedEvent!['min_team_size'] ?? 0,
                              max_team_size: _selectedEvent!['max_team_size'] ?? 0,
                              event_id: _selectedEvent!['id'] ?? '',
                              organizer_id: _selectedEvent!['organizer_id'] ?? '',
                            ),
                          ),
                        );
                      },
                      child: Text("View More"),
                    )
                  ],
                ),
              ),
            ),
          )
              : Text("No events for this date", style: TextStyle(color: Colors.grey)),
        ],
      );

  }
}
