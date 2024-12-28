import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class Medication {
  final String id;
  final String name;
  final int timesPerDay;
  final String alarmTime;
  final String alarmDate;

  Medication({
    required this.id,
    required this.name,
    required this.timesPerDay,
    required this.alarmTime,
    required this.alarmDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'timesPerDay': timesPerDay,
      'alarmTime': alarmTime,
      'alarmDate': alarmDate,
    };
  }

  factory Medication.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Medication(
      id: doc.id,
      name: data['name'] ?? '',
      timesPerDay: data['timesPerDay'] ?? 0,
      alarmTime: data['alarmTime'] ?? '',
      alarmDate: data['alarmDate'] ?? '', // Default value if missing
    );
  }
}

class MedicationReminderPage extends StatefulWidget {
  @override
  _MedicationReminderPageState createState() => _MedicationReminderPageState();
}

class _MedicationReminderPageState extends State<MedicationReminderPage> {
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _timesController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  List<Medication> medications = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('medications').get();

      setState(() {
        medications = querySnapshot.docs
            .map((doc) => Medication.fromDocumentSnapshot(doc))
            .toList();

        medications.sort((a, b) => b.id.compareTo(a.id));
      });
    } catch (e) {
      print("Error loading medications: $e");
    }
  }

  Future<void> _saveMedication() async {
    final medication = Medication(
      id: '',
      name: _medicationController.text,
      timesPerDay: int.tryParse(_timesController.text) ?? 0,
      alarmTime: _timeController.text,
      alarmDate: _dateController.text,
    );

    await FirebaseFirestore.instance
        .collection('medications')
        .add(medication.toMap());

    _scheduleAlarm(medication);
    setState(() {
      _medicationController.clear();
      _timesController.clear();
      _timeController.clear();
      _dateController.clear();
    });

    _loadMedications();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Medication saved and alarm set!')),
    );
  }

  Future<void> _scheduleAlarm(Medication medication) async {
    final timeParts = medication.alarmTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final alarmDateTime = DateFormat('yyyy-MM-dd').parse(medication.alarmDate);
    final alarmTime = DateTime(
      alarmDateTime.year,
      alarmDateTime.month,
      alarmDateTime.day,
      hour,
      minute,
    );

    final timeDifference = alarmTime.difference(DateTime.now());

    if (timeDifference.inMilliseconds > 0) {
      _timer = Timer(timeDifference, () {
        _showSnackBar(medication);
      });
    }

    FlutterAlarmClock.createAlarm(hour: hour, minutes: minute);

    print('Alarm set for ${medication.name} at $alarmTime');
  }

  void _showSnackBar(Medication medication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Time to take your medication: ${medication.name}\n\n'
          'You need to take it ${medication.timesPerDay} times per day.\n'
          'Alarm Time: ${medication.alarmTime}',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 60),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 150, left: 10, right: 10),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _deleteMedication(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(id)
          .delete();

      setState(() {
        medications.removeWhere((medication) => medication.id == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medication deleted successfully!')),
      );
    } catch (e) {
      print("Error deleting medication: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Reminder'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Input Fields (wrapped inside Cards for better presentation)
              _buildInputCard(
                controller: _medicationController,
                label: 'Medication Name',
              ),
              SizedBox(height: 16),
              _buildInputCard(
                controller: _timesController,
                label: 'Times Per Day',
                inputType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _buildInputCard(
                controller: _timeController,
                label: 'Alarm Time (HH:MM)',
              ),
              SizedBox(height: 16),
              _buildDatePickerCard(),
              SizedBox(height: 16),
              _buildSaveButton(),
              SizedBox(height: 32),
              medications.isEmpty
                  ? Center(child: Text('No medications found.'))
                  : _buildMedicationList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(
      {required TextEditingController controller,
      required String label,
      TextInputType inputType = TextInputType.text}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerCard() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Select Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveMedication,
        style: ElevatedButton.styleFrom(
          primary: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Save Reminder',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMedicationList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final medication = medications[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              medication.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${medication.timesPerDay} times per day, Alarm at: ${medication.alarmTime} on ${medication.alarmDate}',
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteMedication(medication.id),
            ),
          ),
        );
      },
    );
  }
}
