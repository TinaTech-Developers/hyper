import 'package:flutter/material.dart';
import 'medication_reminder.dart';
import 'messaging.dart';
import 'education.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DashboardCard(
              title: 'Medication Reminder',
              image: 'assets/images/medication.jpg', // Correct path to image
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MedicationReminderPage()),
                );
              },
            ),
            DashboardCard(
              title: 'Messaging',
              image: 'assets/images/messaging.jpeg',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessagingPage()),
                );
              },
            ),
            DashboardCard(
              title: 'Education',
              image: 'assets/images/education.jpg',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EducationPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const DashboardCard({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color.fromARGB(255, 247, 250, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 8, // Slightly higher elevation for better shadow
        margin: const EdgeInsets.only(bottom: 16.0), // Add space between cards
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Image section
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  image,
                  width: 100, // Set a fixed width for the image
                  height: 60, // Set a fixed height for the image
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16), // Space between image and text
              // Text section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to go to $title',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 65, 63, 63),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
