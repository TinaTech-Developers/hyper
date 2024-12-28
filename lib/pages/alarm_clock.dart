import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';

class AlarmClock extends StatefulWidget {
  /// @{@macro myApp}
  const AlarmClock({Key? key}) : super(key: key);

  @override
  State<AlarmClock> createState() => _AlarmClockState();
}

class _AlarmClockState extends State<AlarmClock> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter alarm clock example'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(25),
                child: TextButton(
                  child: const Text(
                    'Create alarm at 23:59',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    FlutterAlarmClock.createAlarm(hour: 23, minutes: 59);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(25),
                child: const TextButton(
                  onPressed: FlutterAlarmClock.showAlarms,
                  child: Text(
                    'Show alarms',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(25),
                child: TextButton(
                  child: const Text(
                    'Create timer for 42 seconds',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    FlutterAlarmClock.createTimer(length: 42);
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(25),
                child: const TextButton(
                  onPressed: FlutterAlarmClock.showTimers,
                  child: Text(
                    'Show Timers',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}










// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz_data;

// class Medication {
//   final String id;
//   final String name;
//   final int timesPerDay;
//   final String alarmTime;

//   Medication({
//     required this.id,
//     required this.name,
//     required this.timesPerDay,
//     required this.alarmTime,
//   });

//   // Convert Medication to Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'timesPerDay': timesPerDay,
//       'alarmTime': alarmTime,
//     };
//   }

//   // Create Medication from Firestore document
//   factory Medication.fromDocumentSnapshot(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
    
//     return Medication(
//       id: doc.id,
//       name: data['name'] ?? '',  // Default value if missing
//       timesPerDay: data['timesPerDay'] ?? 0,  // Default value if missing
//       alarmTime: data['alarmTime'] ?? '',  // Default value if missing
//     );
//   }
// }

// class MedicationReminderPage extends StatefulWidget {
//   @override
//   _MedicationReminderPageState createState() =>
//       _MedicationReminderPageState();
// }

// class _MedicationReminderPageState extends State<MedicationReminderPage> {
//   final TextEditingController _medicationController = TextEditingController();
//   final TextEditingController _timesController = TextEditingController();
//   final TextEditingController _timeController = TextEditingController();

//   // List of medications fetched from Firestore
//   List<Medication> medications = [];

//   // Notification plugin setup
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   @override
//   void initState() {
//     super.initState();
//     _loadMedications(); // Load medications from Firestore
//     _initializeNotifications(); // Initialize notifications
//   }

//   // Initialize notifications and timezone
//   Future<void> _initializeNotifications() async {
//     tz_data.initializeTimeZones();
//     final AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('app_icon');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse notificationResponse) {
//         final String? payload = notificationResponse.payload;
//         if (payload != null) {
//           _showReminderDialog(payload); // Show reminder on notification tap
//         }
//       },
//     );
//   }

//   // Show a popup dialog when the user taps on the notification
//   void _showReminderDialog(String medicationName) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Reminder'),
//           content: Text('It\'s time to take your medication: $medicationName'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Okay'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Fetch medications from Firestore and sort by creation time (newest first)
//   Future<void> _loadMedications() async {
//     try {
//       final querySnapshot =
//           await FirebaseFirestore.instance.collection('medications').get();

//       // Map Firestore documents to Medication objects and sort by document ID (newest first)
//       setState(() {
//         medications = querySnapshot.docs
//             .map((doc) => Medication.fromDocumentSnapshot(doc))
//             .toList();

//         // Sort medications list from newest to oldest by document ID (since Firestore auto-generates the IDs)
//         medications.sort((a, b) => b.id.compareTo(a.id)); // Compare document IDs (newest first)
//       });

//       if (medications.isEmpty) {
//         print('No medications found!');
//       }
//     } catch (e) {
//       print("Error loading medications: $e");
//     }
//   }

//   // Save medication to Firestore
//   Future<void> _saveMedication() async {
//     final medication = Medication(
//       id: '', // Firestore will auto-generate the ID
//       name: _medicationController.text,
//       timesPerDay: int.tryParse(_timesController.text) ?? 0,
//       alarmTime: _timeController.text,
//     );

//     // Add the medication to Firestore collection
//     await FirebaseFirestore.instance
//         .collection('medications')
//         .add(medication.toMap());

//     // Schedule the alarm for the medication
//     _scheduleNotification(medication);

//     // Clear the input fields
//     setState(() {
//       _medicationController.clear();
//       _timesController.clear();
//       _timeController.clear();
//     });

//     // Reload medications to display the updated list
//     _loadMedications();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Medication saved and reminder set!')),
//     );
//   }

//   // Schedule Notification for a given medication
//   Future<void> _scheduleNotification(Medication medication) async {
//     final timeParts = medication.alarmTime.split(':');
//     final hour = int.parse(timeParts[0]);
//     final minute = int.parse(timeParts[1]);

//     // Get the current local timezone time
//     final now = tz.TZDateTime.now(tz.local);
//     var scheduledTime =
//         tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

//     // If the time has already passed for today, schedule it for tomorrow
//     if (scheduledTime.isBefore(now)) {
//       scheduledTime = scheduledTime.add(Duration(days: 1));
//     }

//     // Create the Android notification details with sound
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'medication_channel',
//       'Medication Reminders',
//       channelDescription: 'Channel for medication reminders',
//       importance: Importance.high,
//       priority: Priority.high,
//       sound: RawResourceAndroidNotificationSound('alarm_sound'), // Correct sound file reference
//     );

//     const NotificationDetails platformDetails =
//         NotificationDetails(android: androidDetails);

//     // Schedule the notification with a payload (medication name)
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       'Time to take your ${medication.name}',
//       'Please take your medication (${medication.name}) now.',
//       scheduledTime, // Correct scheduled time in the local timezone
//       platformDetails,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.wallClockTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//       payload: medication.name, // Passing the medication name as payload
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Medication Reminder'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Medication input form
//             TextField(
//               controller: _medicationController,
//               decoration: InputDecoration(
//                 labelText: 'Medication Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _timesController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Times Per Day',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _timeController,
//               decoration: InputDecoration(
//                 labelText: 'Alarm Time (HH:MM)',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _saveMedication,
//               child: Text('Save Reminder'),
//             ),
//             SizedBox(height: 32),

//             // Medication list display
//             medications.isEmpty
//                 ? Center(child: Text('No medications found.'))
//                 : Expanded(
//                     child: ListView.builder(
//                       itemCount: medications.length,
//                       itemBuilder: (context, index) {
//                         final medication = medications[index];
//                         return Card(
//                           margin: EdgeInsets.symmetric(vertical: 8),
//                           child: ListTile(
//                             title: Text(medication.name),
//                             subtitle: Text(
//                                 '${medication.timesPerDay} times per day, Alarm at: ${medication.alarmTime}'),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }
